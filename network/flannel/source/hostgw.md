# Flannel HostGW源码分析
## Network
Network提供了如下几个接口：
```go
type Network interface {
	Lease() *subnet.Lease
	MTU() int
	Run(ctx context.Context)
}
```
Lease指定了该Network是针对哪个Node，哪个网段的。
Run方法是主流程，会循环watch network中的subnetmanager监听的事件，然后进行对应的处理。处理动作根据backend有所不同。所有对于不同Backend的Network，区别就是对这些事件的处理方式不一样。

### SimpleNetwork
SimpleNetwork是实现网络Network接口的Stub实现——不干任何具体的工作。
```go
type SimpleNetwork struct {
	SubnetLease *subnet.Lease
	ExtIface    *ExternalInterface
}
```

很多其它backend的network都是组合了SimpleNetwork。

### RouteNetwork
RouteNetwork的属性中包含一个netlink.Route列表，以及一个根据Lease获取对应Route的方法。

```go
type RouteNetwork struct {
	SimpleNetwork
	BackendType string
	routes      []netlink.Route
	SM          subnet.Manager
	GetRoute    func(lease *subnet.Lease) *netlink.Route
	Mtu         int
	LinkIndex   int
}
```

每当监测到Node时间时，RouteNetwork根据对应的NodeLease获取相应的Routes，然后将Routes加入到路由表中，后者从路由表剔除该路由。

## HostGW
Hostgw backend network是一个RouteNetwork。
* 每当一个Remote Node加入集群，就在本机增加一条对应的路由。
* 每当一个Remote Node离开集群，就在本机删除一条对应的路由。

