# CNI-calico
## 概述
`calico`提供了`calico-ipam`和`calico`两个plugins。`calico-ipam`用来分配IP，`calico`用来配置pod。
## calico-ipam
`calico-ipam`为一个workload分配IP地址。

在calico网络中，每个Node都分配有一个或者多个IPPool，这些信息保存在etcd中。

calico-ipam就是通过`calico-clitent`获取可用的IP。
1. 获取当前节点的node name，并确定当前workload的标志符。
2. 通过calicoClient解析出来可用的ip pools
3. 通过calicoClient获取ip
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

## calico
calico的网络架构图如下所示：
![](calico_bgp.png)

`calico`的作用就是配置图中的路由器之上的部分。
```go
    hostVethName := k8sconversion.VethNameForWorkload(epIDs.Namespace, epIDs.Pod)
    _, contVethMac, err := utils.DoNetworking(args, conf, result, logger, hostVethName, routes)
```
关键逻辑在`utils.DoNetworking(args, conf, result, logger, hostVethName, routes)`中：
1. 创建veth pair：`contVethName`和`hostVethname`。
2. 为hostVeth配置mac地址`"EE:EE:EE:EE:EE:EE"`
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
3. 在container namespace中，设置`169.254.1.1`作为容器的网关，增加路由条目：
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

4. 为container veth设置IP
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

如此,pod和node之间的网络就联通了!