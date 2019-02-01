# Calico Node
## 概述
Calico Node是一个辅助容器，里面打包了calico网络所需要的几种组件。
其中关键组件包括：
* Felix
* BIRD
* confd
另外，Calico Node使用`runit for logging (svlogd) and init (runsv) services`。

## Felix
The Felix daemon is the heart of Calico networking. Felix’s primary job is to program routes and ACL’s on a workload host to provide desired connectivity to and from workloads on the host.

Felix also programs interface information to the kernel for outgoing endpoint traffic. Felix instructs the host to respond to ARPs for workloads with the MAC address of the host.

## BIRD/BIRD6 internet routing daemon
BIRD is an open source BGP client that is used to exchange routing information between hosts. The routes that Felix programs into the kernel for endpoints are picked up by BIRD and distributed to BGP peers on the network, which provides inter-host routing.

There are two BIRD processes running in the calico/node container. One for IPv4 (bird) and one for IPv6 (bird6).

## confd templating engine
The confd templating engine monitors the etcd datastore for any changes to BGP configuration (and some top level global default configuration such as AS Number, logging levels, and IPAM information).

Confd dynamically generates BIRD configuration files based on the data in etcd, triggered automatically from updates to the data. When the configuration file changes, confd triggers BIRD to load the new files.

Calico uses a fork of the main confd repo which includes an additional change to improve performance with the handling of watch prefixes calico-bird repo for more details.