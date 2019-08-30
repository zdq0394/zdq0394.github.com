# Flannel VxLAN
## VxLan 原理
在[Flanneld 源码分析](flanneld.md)和[Flannel HostGW源码分析](hostgw.md)两节中已经详细分析了network的主流程。
对于不同backend的network来说，就是对event事件的处理方式不同。VxLan Backedn也是如此。
* EventAdded
    * 增加ARP：nw.dev.AddARP
    * 增加FDB：nw.dev.AddFDB
    * 增加Route：netlink.RouteReplace
* EventRemoved
    * 删除ARP：nw.dev.DelARP
    * 删除FDB：nw.dev.DelFDB
    * 删除Route：netlink.RouteDel

针对Vxlan的实现原理，可以参考：[vlan](../../base/vxlan.md)

## VxLan Backend
VxLanBackend的RegisterNetwork方法如下：
```go
	devAttrs := vxlanDeviceAttrs{
		vni:       uint32(cfg.VNI),
		name:      fmt.Sprintf("flannel.%v", cfg.VNI),
		vtepIndex: be.extIface.Iface.Index,
		vtepAddr:  be.extIface.IfaceAddr,
		vtepPort:  cfg.Port,
		gbp:       cfg.GBP,
		learning:  cfg.Learning,
	}

	dev, err := newVXLANDevice(&devAttrs)
	if err != nil {
		return nil, err
	}
	dev.directRouting = cfg.DirectRouting

	subnetAttrs, err := newSubnetAttrs(be.extIface.ExtAddr, dev.MACAddr())
	if err != nil {
		return nil, err
	}
```
1. 根据Subnet配置生成必要的vxlanDeviceAttributes：

* vni默认值为1
* vxlan设备名字：flannel.1
等，

2. 调用`newVXLANDevice`方法在Node节点上创建VxLan设备，并以extIface为基础设备。
3. 第二步骤执行完之后，vxlan设备的mac地址就有了。然后生成subnetAttrs，这个信息会在`AcquireLease`方法中存储到kube/etcd中。

```go
	data, err := json.Marshal(&vxlanLeaseAttrs{hardwareAddr(mac)})
	if err != nil {
		return nil, err
	}

	return &subnet.LeaseAttrs{
		PublicIP:    ip.FromIP(publicIP),
		BackendType: "vxlan",
		BackendData: json.RawMessage(data),
	}, nil
```
4. 给VxLan设备配置IP地址：

IP地址为:ip.IP4Net{IP: lease.Subnet.IP, PrefixLen: 32}。
比如整个flannel的网络为`192.169.0.0/16`，当前node分配的subnet为`192.169.1.0/24`，那么vxlan设备分配的地址就是`192.169.1.0/32`。

5. 创建network：

```go
return newNetwork(be.subnetMgr, be.extIface, dev, ip.IP4Net{}, lease)
```
参数分别为：
* subnetmanager
* 物理设备
* vxlan设备
* 空的IP
* 节点信息lease
```go
func newNetwork(subnetMgr subnet.Manager, extIface *backend.ExternalInterface, dev *vxlanDevice, _ ip.IP4Net, lease *subnet.Lease) (*network, error) {
	nw := &network{
		SimpleNetwork: backend.SimpleNetwork{
			SubnetLease: lease,
			ExtIface:    extIface,
		},
		subnetMgr: subnetMgr,
		dev:       dev,
	}

	return nw, nil
}
```
## VxLan Network
```go
type network struct {
	backend.SimpleNetwork
	dev       *vxlanDevice
	subnetMgr subnet.Manager
}
```
* dev：指虚拟出来的VxLan设备，比如flannel.1。

对于vxlan network的MTU则定义：
```go
func (nw *network) MTU() int {
	return nw.ExtIface.Iface.MTU - encapOverhead
}
```
其中encapOverhead=50，及MTU=ExternalInterface的MTU-50，默认为1500-50=1450。

重点分析handleSubnetEvents(batch []subnet.Event)方法：
1. 生成Remote node的路由。
```go
        sn := event.Lease.Subnet
        ...
        vxlanRoute := netlink.Route{
			LinkIndex: nw.dev.link.Attrs().Index,
			Scope:     netlink.SCOPE_UNIVERSE,
			Dst:       sn.ToIPNet(),
			Gw:        sn.IP.ToIP(),
        }
```
* 设备：当前node的vxlan设备——flannel.1，此处用的是Index指定。
* 目的地址：对端subnet的IP网络地址，比如`192.169.2.0/24`
* 网关地址：对端subnet的IP网关地址，比如`192.169.2.0`

### EventAdded事件：
1. nw.dev.AddARP(neighbor{IP: sn.IP, MAC: net.HardwareAddr(vxlanAttrs.VtepMAC)})

增加ARP：增加remote node上vxlan设备的IP地址和MAC地址对应关系到本机ARP表
192.169.2.0/32->MAC地址(192.169.2.0)

2. nw.dev.AddFDB(neighbor{IP: attrs.PublicIP, MAC: net.HardwareAddr(vxlanAttrs.VtepMAC)})

增加FDB：增加remote node上vxlan设备的mac地址的下一跳。
MAC地址(192.169.2.0)-> publicIP vtep地址

3. netlink.RouteReplace(&vxlanRoute)
增加路由信息

### EventRemoved事件：
将EventAdded中三个步骤增加的信息删除。
