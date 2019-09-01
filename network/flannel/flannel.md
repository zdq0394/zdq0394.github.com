# Flannel网络架构
## 概述
Flannel网络是一个IP网络。

每个node之上的容器构成一个`容器二层网络`，可以通过bridge互联，bridge设备设置网关IP，每个容器都设置默认路由为该网关。

各个node之间是一个`节点二层网络`。
* 如果node之间本来就在一个`二层网络`，则可以采用`hostgw`模式构建。
* 如果node之间不是一个`二层网络`，则通过`vxlan`技术在物理ip网络上overlay一个`二层网络`

节点Linux内核开启IP Forward功能。通过路由表联通`容器二层网络`和`节点二层网络`。这也是为什么节点之间一定要处于一个`二层网络`？
因为需要flanneld配置路由表使得容器网络和节点网络联通，而flanned只能修改节点上的路由表，操纵节点这个虚拟路由器，无法操作节点间的物理路由器。鉴于此，如果underlay网络是二层网络，就采用hostgw模式；如果underlay网络不是二层网络，就使用vxlan技术overlay一个二层网络。

原理都一样。只是vxlan比hostgw多了一次解包和封包的过程，性能当然要比hostgw差了一些。

## 网络基础
### bridge
* [bridge](../base/bridge.md)
* [bridge 三层网络](../base/bridge_route.md)
### vxlan
* [vxlan](../base/vxlan.md)
## hostgw
Backend `hostgw`形式的网络架构图：

![](pics/flannel_hostgw.png)

## vxlan
Backend `vxlan`形式的网络架构图：

![](pics/flannel_vxlan.png)