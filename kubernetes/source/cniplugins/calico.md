# CNI-calico
## 概述
`calico`提供了`calico-ipam`和`calico`两个plugins。
* `calico-ipam`为workload分配IP。其中IP的信息保存在calico的后端etcd中。
* `calico`用来配置workload的interface，并构建路由，使得workload和host互通。
## calico-ipam
`calico-ipam`为一个workload分配IP地址。
### IPPool
在calico网络中，配置有一个或者多个IPPools。可以通过如下命令查看Calico网络当前的ippools：
```sh
# calicoctl get ippools -o yaml
apiVersion: projectcalico.org/v3
kind: IPPoolList
items:
- apiVersion: projectcalico.org/v3
  kind: IPPool
  metadata:
    name: default-ipv4-ippool
    resourceVersion: "4843135"
  spec:
    cidr: 192.168.0.0/16
    ipipMode: Never
    natOutgoing: true
```

当调用`calico-ipam`为workload分配IP时，就从配置好的IPPools分配一个IP。

新增一个IPPool的命令为：
```sh
# calicoctl create -f -<<EOF
apiVersion: projectcalico.org/v3
kind: IPPool
metadata:
  name: new-pool
spec:
  cidr: 10.0.0.0/16
  ipipMode: Always
  natOutgoing: true
EOF
```
### calico-ipam流程
calico-ipam通过`calico-client`从Calico网络中已经配置的IPPools中获取可用的IP。

1. 获取当前节点的node name，并确定当前workload的标志符。
2. 通过calicoClient解析出来有效的ip pools，这些IPPools可能是通过名字提供的。
3. 然后以assignArgs为参数，调用`calicoClient.IPAM().AutoAssign`分配IP。
```go
....
nodename := utils.DetermineNodename(conf)
....
calicoClient, err := utils.CreateClient(conf)
....
epIDs, err := utils.GetIdentifiers(args, nodename)
epIDs.WEPName, err = epIDs.CalculateWorkloadEndpointName(false)
handleID, err := utils.GetHandleID(conf.Name, args.ContainerID, epIDs.WEPName)
....
v4pools, err := utils.ResolvePools(ctx, calicoClient, conf.IPAM.IPv4Pools, true)
....
        assignArgs := ipam.AutoAssignArgs{
			Num4:      num4,
			Num6:      num6,
			HandleID:  &handleID,
			Hostname:  nodename,
			IPv4Pools: v4pools,
			IPv6Pools: v6pools,
		}
		logger.WithField("assignArgs", assignArgs).Info("Auto assigning IP")
        assignedV4, assignedV6, err := calicoClient.IPAM().AutoAssign(ctx, assignArgs)
....
```
分配IP的过程很复杂。
* 可以自定义提供IP地址
* 可以自定义提供cidr，但是该cidr要在配置的IPPools范围内

## calico
### calico网络架构图
calico的网络架构图如下所示：
![](calico_bgp.png)

### calico主流程
`calico`的作用就是配置图中的路由器之上的部分包含的设备、IP、MAC和路由以及系统设置（开启IPForward和ARPProxy）。

`calico`不但支持Kubernetes，还支持其它的编排器。这里只分析Kubernetes相关的源代码，即`cni-plugin/pkg/k8s/k8s.go`文件中CmdAddK8s函数。

1. 首先会准备容器的默认路由。这里只提供的默认路由只有dest。
```go
	// Determine which routes to program within the container. If no routes were provided in the CNI config,
	// then use the Calico default routes. If routes were provided then program those instead.
	if len(routes) == 0 {
		logger.Debug("No routes specified in CNI configuration, using defaults.")
		routes = utils.DefaultRoutes
	} else {
		if conf.IncludeDefaultRoutes {
			// We're configured to also include our own default route, so do that here.
			logger.Debug("Including Calico default routes in addition to routes from CNI config")
			routes = append(utils.DefaultRoutes, routes...)
		}
		logger.WithField("routes", routes).Info("Using custom routes from CNI configuration.")
    }
```
2. 设置PolicyType。暂时不分析此处代码。
3. 使用IPAM插件分配IP地址。
4. 进入关键步骤，构建并配置网络设备。关键逻辑在`utils.DoNetworking(args, conf, result, logger, hostVethName, routes)`中：
```go
    hostVethName := k8sconversion.VethNameForWorkload(epIDs.Namespace, epIDs.Pod)
    _, contVethMac, err := utils.DoNetworking(args, conf, result, logger, hostVethName, routes)
```
5. 将创建完成的网络设备，尤其是mac地址添加/更新到calico的etcd中
```go
	endpoint.Spec.MAC = mac.String()
	endpoint.Spec.InterfaceName = hostVethName
    endpoint.Spec.ContainerID = epIDs.ContainerID
    ....
	// Write the endpoint object (either the newly created one, or the updated one)
	if _, err := utils.CreateOrUpdate(ctx, calicoClient, endpoint); err != nil {
		logger.WithError(err).Error("Error creating/updating endpoint in datastore.")
		releaseIPAM()
		return nil, err
	}
```
### DoNetworking流程
本部分代码在`cni-plugin/internal/pkg/utils/network_linux.go`中：
DoNetworking流程可以分为两部分。
* 第一部分在container ns中执行。
* 第二部分在host ns中执行。

先看第一部分：
1. 创建veth pair：`contVethName`和`hostVethname`
kubernetes中hostVethName是由外界通过desiredVethName传入的。
```go
    hostVethName = "cali" + args.ContainerID[:Min(11, len(args.ContainerID))]
....
	// If a desired veth name was passed in, use that instead.
	if desiredVethName != "" {
		hostVethName = desiredVethName
	}
```

```go
        veth := &netlink.Veth{
			LinkAttrs: netlink.LinkAttrs{
				Name:  contVethName,
				Flags: net.FlagUp,
				MTU:   conf.MTU,
			},
			PeerName: hostVethName,
        }
		if err := netlink.LinkAdd(veth); err != nil {
			logger.Errorf("Error adding veth %+v: %s", veth, err)
			return err
		}
```
2. 为hostVeth配置mac地址`"EE:EE:EE:EE:EE:EE"`：
```go
		hostVeth, err := netlink.LinkByName(hostVethName)

		if mac, err := net.ParseMAC("EE:EE:EE:EE:EE:EE"); err != nil {
			logger.Infof("failed to parse MAC Address: %v. Using kernel generated MAC.", err)
		} else {
			// Set the MAC address on the host side interface so the kernel does not
			// have to generate a persistent address which fails some times.
			if err = netlink.LinkSetHardwareAddr(hostVeth, mac); err != nil {
				logger.Warnf("failed to Set MAC of %q: %v. Using kernel generated MAC.", hostVethName, err)
			}
		}

		if err = netlink.LinkSetUp(hostVeth); err != nil {
			return fmt.Errorf("failed to set %q up: %v", hostVethName, err)
		}
```
3. 设置`169.254.1.1`作为容器的网关，增加路由条目：
    * 169.254.1.1 dev eth0 scope link
    * default via 169.254.1.1 dev eth0
```go
            gw := net.IPv4(169, 254, 1, 1)
			gwNet := &net.IPNet{IP: gw, Mask: net.CIDRMask(32, 32)}
			err := netlink.RouteAdd(
				&netlink.Route{
					LinkIndex: contVeth.Attrs().Index,
					Scope:     netlink.SCOPE_LINK,
					Dst:       gwNet,
				},
			)

			if err != nil {
				return fmt.Errorf("failed to add route inside the container: %v", err)
			}

			for _, r := range routes {
				if r.IP.To4() == nil {
					logger.WithField("route", r).Debug("Skipping non-IPv4 route")
					continue
				}
				logger.WithField("route", r).Debug("Adding IPv4 route")
				if err = ip.AddRoute(r, gw, contVeth); err != nil {
					return fmt.Errorf("failed to add IPv4 route for %v via %v: %v", r, gw, err)
				}
            }
```

4. 为container veth设置IP地址：
这些地址是由`ipam`插件分配的。
```go
        // Now add the IPs to the container side of the veth.
		for _, addr := range result.IPs {
			if err = netlink.AddrAdd(contVeth, &netlink.Addr{IPNet: &addr.Address}); err != nil {
				return fmt.Errorf("failed to add IP addr to %q: %v", contVeth, err)
			}
        }
```

5. 在container namespace中设置IP转发。
```go
// configureContainerSysctls configures necessary sysctls required inside the container netns.
func configureContainerSysctls(logger *logrus.Entry, settings types.ContainerSettings, hasIPv4, hasIPv6 bool) error {
	// If an IPv4 address is assigned, then configure IPv4 sysctls.
	if hasIPv4 {
		if settings.AllowIPForwarding {
			logger.Info("Enabling IPv4 forwarding")
			if err := writeProcSys("/proc/sys/net/ipv4/ip_forward", "1"); err != nil {
				return err
			}
		} else {
			logger.Info("Disabling IPv4 forwarding")
			if err := writeProcSys("/proc/sys/net/ipv4/ip_forward", "0"); err != nil {
				return err
			}
		}
    }
}
```
6. 把hostVeth转移到host namespace中
```go		
        // Now that the everything has been successfully set up in the container, move the "host" end of the
		// veth into the host namespace.
		if err = netlink.LinkSetNsFd(hostVeth, int(hostNS.Fd())); err != nil {
			return fmt.Errorf("failed to move veth to host netns: %v", err)
        }
```
此处开始第二阶段，都在host namespace中执行。

7. 开启hostVeth端的arp proxy功能
```go
// configureSysctls configures necessary sysctls required for the host side of the veth pair for IPv4 and/or IPv6.
func configureSysctls(hostVethName string, hasIPv4, hasIPv6 bool) error {
	var err error

	if hasIPv4 {
		// Normally, the kernel has a delay before responding to proxy ARP but we know
		// that's not needed in a Calico network so we disable it.
		if err = writeProcSys(fmt.Sprintf("/proc/sys/net/ipv4/neigh/%s/proxy_delay", hostVethName), "0"); err != nil {
			return fmt.Errorf("failed to set net.ipv4.neigh.%s.proxy_delay=0: %s", hostVethName, err)
		}

		// Enable proxy ARP, this makes the host respond to all ARP requests with its own
		// MAC. We install explicit routes into the containers network
		// namespace and we use a link-local address for the gateway.  Turing on proxy ARP
		// means that we don't need to assign the link local address explicitly to each
		// host side of the veth, which is one fewer thing to maintain and one fewer
		// thing we may clash over.
		if err = writeProcSys(fmt.Sprintf("/proc/sys/net/ipv4/conf/%s/proxy_arp", hostVethName), "1"); err != nil {
			return fmt.Errorf("failed to set net.ipv4.conf.%s.proxy_arp=1: %s", hostVethName, err)
		}

		// Enable IP forwarding of packets coming _from_ this interface.  For packets to
		// be forwarded in both directions we need this flag to be set on the fabric-facing
		// interface too (or for the global default to be set).
		if err = writeProcSys(fmt.Sprintf("/proc/sys/net/ipv4/conf/%s/forwarding", hostVethName), "1"); err != nil {
			return fmt.Errorf("failed to set net.ipv4.conf.%s.forwarding=1: %s", hostVethName, err)
		}
    }
    ....
}
```
8. 增加经过hostVeth到workload的路由:
目的地址: container ip
Link: hostVeth
Scope: link
```go
		route := netlink.Route{
			LinkIndex: hostVeth.Attrs().Index,
			Scope:     netlink.SCOPE_LINK,
			Dst:       &ipAddr.Address,
		}
        err := netlink.RouteAdd(&route)
```

此时：pod和node之间的网络就联通了。

