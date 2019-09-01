# Flannel网络架构
## 概述
Flannel网络是一个IP网络。

每个node之上的容器构成一个`容器二层网络`，可以通过bridge互联，bridge设备设置网关IP，每个容器都设置默认路由为该网关。

各个node之间是一个`节点二层网络`。
* 如果node之间本来就在一个`二层网络`，则可以采用`hostgw`模式构建。
* 如果node之间不是一个`二层网络`，则通过`vxlan`技术在物理ip网络上overlay一个`二层网络`

节点Linux内核开启IP Forward功能。通过路由表联通`容器二层网络`和`节点二层网络`。

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