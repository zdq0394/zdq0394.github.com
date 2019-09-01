# CNI-Flannel
## 概述
Flanneld构建了跨主机的网络通信fabric。无论Backend是VxLAN还是Hostgw，在每个节点上都有一个设备（VxLAN设备或者物理网卡），这些设备在二层是相通的（VxLAN是Layer2 over Layer3）。
如下图所示：
![](flannel_vxlan.png)

Flanneld构建了图中个节点路由器以下部分的Fabric，并且在节点上构建了通过该fabric到达Remote Node的Subnet的路由信息。

那么如何构建节点上Pod与节点间的fabric呢？也就是节点的subnet是如何构建的？这就是flannel plugin的作用范围了。

Flannel plugin只是根据Flanneld分配的子网，构建一个delegate plugin（主要是Bridge）的网络配置，借助delegate plugin配置网络。

## Flannel
Flannel的[源码地址](https://github.com/containernetworking/plugins/tree/master/plugins/meta/flannel)
### Flannel网络配置
Flanneld运行之后，会在节点上输出一个subnet.env文件，将把Subnet信息写入到SubnetFile中`/run/flannel/subnet.env`。

内容大概如下:
```
FLANNEL_NETWORK=192.169.0.0/16
FLANNEL_SUBNET=192.169.1.1/24
FLANNEL_MTU=1450
FLANNEL_IPMASQ=false
```

Flannel plugin的网络配置文件如下：
```json
{
	"name": "mynet",
	"type": "flannel"
}
```
或者
```json
{
	"name": "mynet",
    "type": "flannel",
    "delegate": {
        "bridge": "mynet0"
    }
}
```

flannel中定义了两个结构体：
```go
type NetConf struct {
	types.NetConf

	SubnetFile    string                 `json:"subnetFile"`
	DataDir       string                 `json:"dataDir"`
	Delegate      map[string]interface{} `json:"delegate"`
	RuntimeConfig map[string]interface{} `json:"runtimeConfig,omitempty"`
}

type subnetEnv struct {
	nw     *net.IPNet
	sn     *net.IPNet
	mtu    *uint
	ipmasq *bool
}

```

根据CNI框架，网络配置文件NetConf会以stdin传给插件代码，CNI skel将其封装在args的stdinData中。而对于subnet.env文件，由flannel本地加载。

### flannel.cmdAdd
cmdAdd的主要流程：
1. 加载网络配置文件和subnet.env文件。
2. 对网络配置中的delegate进行验证。
3. 封装针对delegate plugin——默认是bridge的网络配置。
4. 调用delegate plugin。

封装delegate plugin的代码。
* delegate的网络类型默认是bridge。
* delegate的ipMasq设置和flannel的设置是相反的。
* mtu值设置为flannel的mtu。
* 默认bridge模式下设置bridge作为网关。
* 构造delegate plugin的ipam插件为`host-local`。
```go
	n.Delegate["name"] = n.Name

	if !hasKey(n.Delegate, "type") {
		n.Delegate["type"] = "bridge"
	}

	if !hasKey(n.Delegate, "ipMasq") {
		// if flannel is not doing ipmasq, we should
		ipmasq := !*fenv.ipmasq
		n.Delegate["ipMasq"] = ipmasq
	}

	if !hasKey(n.Delegate, "mtu") {
		mtu := fenv.mtu
		n.Delegate["mtu"] = mtu
	}

	if n.Delegate["type"].(string) == "bridge" {
		if !hasKey(n.Delegate, "isGateway") {
			n.Delegate["isGateway"] = true
		}
	}
	if n.CNIVersion != "" {
		n.Delegate["cniVersion"] = n.CNIVersion
	}

	n.Delegate["ipam"] = map[string]interface{}{
		"type":   "host-local",
		"subnet": fenv.sn.String(),
		"routes": []types.Route{
			{
				Dst: *fenv.nw,
			},
		},
	}

	return delegateAdd(args.ContainerID, n.DataDir, n.Delegate)
```
## bridge
Linux bridge是一个网桥设备，可以在linux系统中构建一个二层网络。
如何通过bridge构建网络可以参考
* [bridge二层](../../../network/base/bridge.md)
* [bridge网络](../../../network/base/bridge_route.md)

`bridge plugin`是一个基础的plugin。
### bridge.cmdAdd
1. 创建bridge设备：`br, brInterface, err := setupBridge(n)`
2. 创建veth pair，并把host端的veth加入到bridge中
```go
hostInterface, containerInterface, err := setupVeth(netns, br, args.IfName, n.MTU, n.HairpinMode, n.Vlan)
...
	// connect host veth end to the bridge
	if err := netlink.LinkSetMaster(hostVeth, br); err != nil {
		return nil, nil, fmt.Errorf("failed to connect %q to bridge %v: %v", hostVeth.Attrs().Name, br.Attrs().Name, err)
	}

	// set hairpin mode
	if err = netlink.LinkSetHairpin(hostVeth, hairpinMode); err != nil {
		return nil, nil, fmt.Errorf("failed to setup hairpin mode for %v: %v", hostVeth.Attrs().Name, err)
    }
...
```
3. 执行ipam plugin获取ip地址和gateway地址
```go
r, err := ipam.ExecAdd(n.IPAM.Type, args.StdinData)
```
4. 给container端的veth设置ip地址和路由
```go
            // Add the IP to the interface
			if err := ipam.ConfigureIface(args.IfName, result); err != nil {
				return err
            }
```
在ConfigureIface方法中会设置IP地址，并配置路由。这一切当然都是pod namespace中的。

5. 给bridge配置subnet的网关地址，并开启ip forward转发，开启Linux服务器的路由功能。
6. 如果网络开启了Masq，配置相应的iptables中的nat规则。

总结：

最终构建了bridge基础的二层网络，并配置相应的IP地址和网关。也就是图中每个节点的subnet子网。ipforward开启之后，linux内核具有路由功能，也就是图中的路由器。