# Flannel Hostgw源码分析
## Network
Network是一个逻辑的概念，它包含了一个SubnetManager和一个Backend以及一个ExternalInterface。
* SubnetManager监听node节点的变化。
* Backend实现网络的状态更新。
* ExternalInterface是具体的物理链路。

Network提供了如下几个接口：
```go
type Network interface {
	Lease() *subnet.Lease
	MTU() int
	Run(ctx context.Context)
}
```
* Lease指定了该Network是针对哪个Node，本node负责哪个网段。
* Run方法是主流程，会循环watch network中的subnetmanager监听到的事件，然后进行对应的处理。不同的backend的处理方式是不一样的。

### SimpleNetwork
SimpleNetwork是Network接口的Stub实现——它不干任何具体的工作。
```go
type SimpleNetwork struct {
	SubnetLease *subnet.Lease
	ExtIface    *ExternalInterface
}
```

其它backend的network大多都是组合了SimpleNetwork来实现的。

### RouteNetwork
RouteNetwork是一个比较`通用`路由网络。
RouteNetwork中包含一个netlink.Route列表，以及一个根据Lease获取对应Route的方法。

RouteNetwork就是通过维持节点上路由表的更新，来维护网络状态。

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
我们看RouteNetwork的方法：(n *RouteNetwork) handleSubnetEvents(batch []subnet.Event)，只保留主要部分。

```go
	for _, evt := range batch {
		switch evt.Type {
		case subnet.EventAdded:
			log.Infof("Subnet added: %v via %v", evt.Lease.Subnet, evt.Lease.Attrs.PublicIP)
			...
			route := n.GetRoute(&evt.Lease)
			...
			n.addToRouteList(*route)
			...
		case subnet.EventRemoved:
			log.Info("Subnet removed: ", evt.Lease.Subnet)
			...
			route := n.GetRoute(&evt.Lease)
			// Always remove the route from the route list.
			n.removeFromRouteList(*route)
		default:
			log.Error("Internal error: unknown event type: ", int(evt.Type))
		}
	}
```

* 当监测到Node Added时，RouteNetwork根据对应的Lease获取相应的Routes，然后将Routes加入到路由表中。
* 当检测到Node Removed时，RouteNetwork根据对应的Lease获取相应的Routes，然后将Routes从到路由表中删除。

RouteNetwork还有一个独立的goroutine，定时检查routes的一致性，确保routes的路由信息都写入了node路由表中。
```go
func (n *RouteNetwork) routeCheck(ctx context.Context) {
	for {
		select {
		case <-ctx.Done():
			return
		case <-time.After(routeCheckRetries * time.Second):
			n.checkSubnetExistInRoutes()
		}
	}
}

采用RouteNetwork的不同Backend其实只要重新定义`GetRoute    func(lease *subnet.Lease) *netlink.Route`方法就可以了。比如，HostgwBackend。

```
## Hostgw Backend
Hostgw backend的network是一个RouteNetwork。
* 每当一个Remote Node加入集群，就在本机增加一条对应的路由。
* 每当一个Remote Node离开集群，就在本机删除一条对应的路由。

Hostgw的`GetRoute`方法如下：
```go
	n.GetRoute = func(lease *subnet.Lease) *netlink.Route {
		return &netlink.Route{
			Dst:       lease.Subnet.ToIPNet(),
			Gw:        lease.Attrs.PublicIP.ToIP(),
			LinkIndex: n.LinkIndex,
		}
	}
```

* Remote Node的Subnet IP作为Dst
* Remote Node的Public IP作为Gw
