# Docker Bridge网络解析
默认，所有的Docker宿主机都有`bridge`网络。
## 初始`bridge`网络信息
通过`docker inspect bridge`命令查看网络信息：
```
# docker inspect bridge
[
    {
        "Name": "bridge",
        "Id": "7d1db683c0704cfbb0be3fbf5c636ab63fbc2eee3a5ca58aa3ba8d9a67607808",
        "Created": "2017-12-15T21:29:20.582306587+08:00",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": null,
            "Config": [
                {
                    "Subnet": "172.17.0.0/16"
                }
            ]
        },
        "Internal": false,
        "Attachable": false,
        "Ingress": false,
        "ConfigFrom": {
            "Network": ""
        },
        "ConfigOnly": false,
        "Containers": {},
        "Options": {
            "com.docker.network.bridge.default_bridge": "true",
            "com.docker.network.bridge.enable_icc": "true",
            "com.docker.network.bridge.enable_ip_masquerade": "true",
            "com.docker.network.bridge.host_binding_ipv4": "0.0.0.0",
            "com.docker.network.bridge.name": "docker0",
            "com.docker.network.driver.mtu": "1500"
        },
        "Labels": {}
    }
]
```
可以看出该网络的`"Driver": "bridge"`；宿主机上的网桥名字：`"com.docker.network.bridge.name": "docker0"`；网络地址范围： `"Subnet": "172.17.0.0/16"`。

因为我们没有创建任何容器，`"Containers": {},`，表示该网络中没有任何容器。

## 创建容器

执行如下命令，创建两个容器。

```sh
# docker run -itd --name=container1 busybox
73efb138b1eb2ae990466696f47a66f9647e20c5ecc2c1faf2c2cc8c2a4f94e4
# docker run -itd --name=container2 busybox
db937eba7da4640e55010b0b10564abfb8c924d5699999882f2ac3520373aaab
```
### 查看网络信息
再次执行`docker inspect bridge`命令，可以发现，container不再为空。
```json
...
 "Containers": {
            "Containers": {
            "73efb138b1eb2ae990466696f47a66f9647e20c5ecc2c1faf2c2cc8c2a4f94e4": {
                "Name": "container1",
                "EndpointID": "3752b4fd65119102960b1aabc7b01d788189f1a04be936300e21d2d91d906fe4",
                "MacAddress": "02:42:ac:11:00:02",
                "IPv4Address": "172.17.0.2/16",
                "IPv6Address": ""
            },
            "db937eba7da4640e55010b0b10564abfb8c924d5699999882f2ac3520373aaab": {
                "Name": "container2",
                "EndpointID": "2194bc39506d956e30be239abea27d0d8c766927ee0e0245804c32cc08a4c12f",
                "MacAddress": "02:42:ac:11:00:03",
                "IPv4Address": "172.17.0.3/16",
                "IPv6Address": ""
            }
        },

        },
...
```
网络中增加了我们刚才创建的两个容器，网络地址分别为`172.17.0.2`和`172.17.0.3`。
### 网络连通性测试
首先测试宿主机到容器的连通性。
```sh
# ping 172.17.0.2
PING 172.17.0.2 (172.17.0.2) 56(84) bytes of data.
64 bytes from 172.17.0.2: icmp_seq=1 ttl=64 time=0.100 ms
64 bytes from 172.17.0.2: icmp_seq=2 ttl=64 time=0.069 ms

# ping 172.17.0.3
PING 172.17.0.3 (172.17.0.3) 56(84) bytes of data.
64 bytes from 172.17.0.3: icmp_seq=1 ttl=64 time=0.097 ms
64 bytes from 172.17.0.3: icmp_seq=2 ttl=64 time=0.064 ms
64 bytes from 172.17.0.3: icmp_seq=3 ttl=64 time=0.064 ms
```

然后测试容器之间的连通性。

我们登陆到`container1`中，可以发现container1的ip地址为`172.17.0.2/16`，可以ping通另外一个容器和宿主机。
```sh
docker attach container1
/ # ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue qlen 1
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
14: eth0@if15: <BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 1500 qdisc noqueue 
    link/ether 02:42:ac:11:00:02 brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.2/16 scope global eth0
       valid_lft forever preferred_lft forever
/ # ping 172.17.0.3
PING 172.17.0.3 (172.17.0.3): 56 data bytes
64 bytes from 172.17.0.3: seq=0 ttl=64 time=0.125 ms
64 bytes from 172.17.0.3: seq=1 ttl=64 time=0.135 ms
^C
--- 172.17.0.3 ping statistics ---
2 packets transmitted, 2 packets received, 0% packet loss
round-trip min/avg/max = 0.125/0.130/0.135 ms
/ # ping 172.17.0.1
PING 172.17.0.1 (172.17.0.1): 56 data bytes
64 bytes from 172.17.0.1: seq=0 ttl=64 time=0.112 ms
64 bytes from 172.17.0.1: seq=1 ttl=64 time=0.135 ms
^C
--- 172.17.0.1 ping statistics ---
2 packets transmitted, 2 packets received, 0% packet loss
round-trip min/avg/max = 0.112/0.123/0.135 ms
/ # 

```
同样，可以登陆到container2上重复上述操作。

## 网络联通性veth pair对跟踪
在宿主机上执行`ip a`命令可以发现多了两个网卡：
``` sh
15: veth15e0a98@if14: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master docker0 state UP group default 
    link/ether 6a:42:25:20:62:c0 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet6 fe80::6842:25ff:fe20:62c0/64 scope link 
       valid_lft forever preferred_lft forever
17: veth138e121@if16: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master docker0 state UP group default 
    link/ether 8a:0c:77:72:b6:28 brd ff:ff:ff:ff:ff:ff link-netnsid 1
    inet6 fe80::880c:77ff:fe72:b628/64 scope link 
       valid_lft forever preferred_lft forever
```

在宿主机上执行`brctl show`可以发现网桥`docker0`上attach了两个网卡，刚好是新增的两个网卡`veth138e121`和`veth15e0a98`。
``` sh
# brctl show
bridge name	bridge id		STP enabled	interfaces
docker0		8000.0242a837f8cc	no		veth138e121
							            veth15e0a98
```

我们来看`15: veth15e0a98@if14`：从名字可以看出这个网卡是一个veth pair的一端，这个网卡的index是15。

从名字@if14也可以看出，veth pair的对端index是`14`。
当然，不能只看名字，宿主机上执行如下命令：
```sh
# ethtool -S veth15e0a98
NIC statistics:
     peer_ifindex: 14
```
那么ifindex为14的veth在哪里，显然不在宿主机的namespace里，而是在容器的namespace中。

执行命令`docker inspect container1`可以发现
```json
...
"NetworkSettings": {
            "Bridge": "",
            "SandboxID": "467c0ddd4651db45922e9f553630acef4303085c3f2391b7f399e7879ada0e6b",
            "HairpinMode": false,
            "LinkLocalIPv6Address": "",
            "LinkLocalIPv6PrefixLen": 0,
            "Ports": {},
            "SandboxKey": "/var/run/docker/netns/467c0ddd4651",
            "SecondaryIPAddresses": null,
            "SecondaryIPv6Addresses": null,
            "EndpointID": "3752b4fd65119102960b1aabc7b01d788189f1a04be936300e21d2d91d906fe4",
            "Gateway": "172.17.0.1",
            "GlobalIPv6Address": "",
            "GlobalIPv6PrefixLen": 0,
            "IPAddress": "172.17.0.2",
            "IPPrefixLen": 16,
            "IPv6Gateway": "",
            "MacAddress": "02:42:ac:11:00:02",
            "Networks": {
                "bridge": {
                    "IPAMConfig": null,
                    "Links": null,
                    "Aliases": null,
                    "NetworkID": "7d1db683c0704cfbb0be3fbf5c636ab63fbc2eee3a5ca58aa3ba8d9a67607808",
                    "EndpointID": "3752b4fd65119102960b1aabc7b01d788189f1a04be936300e21d2d91d906fe4",
                    "Gateway": "172.17.0.1",
                    "IPAddress": "172.17.0.2",
                    "IPPrefixLen": 16,
                    "IPv6Gateway": "",
                    "GlobalIPv6Address": "",
                    "GlobalIPv6PrefixLen": 0,
                    "MacAddress": "02:42:ac:11:00:02",
                    "DriverOpts": null
                }
            }
        }

...
```
容器的SandboxID，以及目录。
执行 `ln -s /var/run/docker/netns/467c0ddd4651 /var/run/netns/467c0ddd4651`
然后执行`ip netns exec 467c0ddd4651 ip a`：
```sh
# ip netns exec 467c0ddd4651 ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
14: eth0@if15: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
    link/ether 02:42:ac:11:00:02 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 172.17.0.2/16 scope global eth0
       valid_lft forever preferred_lft forever
```
终于在`container1`的namespace下面发现了ifindex为14的veth，并且该veth的IP地址和mac地址和`docker inspect container1`完全一致。

执行如下命令，正好可以验证，该veth的对端是veth15e0a98，ifindex是15。
```sh
ip netns exec 467c0ddd4651 ethtool -S eth0
NIC statistics:
     peer_ifindex: 15
```
