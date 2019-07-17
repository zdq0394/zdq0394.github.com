# Kubernetes CNI与Calico组件交互流程
## CNI Plugin
`cni-plugin`会在指定的network ns中创建veth pair。

位于容器中的veth，将被设置容器的ip（比如192.168.8.42），并设置169.254.1.1为`默认路由`，在容器内可以看到:

```sh
$ip route
default via 169.254.1.1 dev eth0
169.254.1.1 dev eth0  scope link
```
因为169.254.1.1是无效IP，因此，cni-plugin还要在容器内设置一条静态arp:

```sh
$ip neighbor
169.254.1.1 dev eth0 lladdr ea:88:97:5f:06:d9 STALE
```

169.254.1.1的mac地址被设置为了veth设备在host中的一端mac地址，容器中所有的报文就会发送到了veth的host端。

cni-plugin创建了endpoint之后，会将其保存到etcd中，felix从而感知到host端endpoint的变化。

## felix
felix监听endpoint状态更新，然后设置所在node上的数据面(dataplane)。

## bird
Bird是一个BGP client，它会主动读取felix在host上设置的路由信息，然后通过BGP协议广播出去。