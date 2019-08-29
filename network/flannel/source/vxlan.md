# Flannel VxLAN
## VxLan network
在[Flanneld 源码分析](flanneld.md)和[Flannel HostGW源码分析](hostgw.md)两节中已经详细分析了network的主流程。

对于不同backend的network来说，就是对event事件的处理方式不同。 VxLan backend的网络如何处理这些事件呢？根据事件类型分两种情况：

### EventAdded
* 增加ARP：nw.dev.AddARP
* 增加FDB：nw.dev.AddARP
* 增加Route：netlink.RouteReplace

### EventRemoved
* 删除ARP：nw.dev.DelARP
* 删除FDB：nw.dev.DelFDB
* 删除Route：netlink.RouteDel