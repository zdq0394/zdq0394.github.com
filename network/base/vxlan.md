# VxLan
## 概述
Virutal eXtensible Local Area Network。
## 基本场景
### configure two hosts using remote

* host1: eth0, 10.128.147.181
* host2: eth0, 10.128.147.182

在host1执行如下命令：
```sh
ip link add vxlan100 type vxlan id 100 remote 10.128.147.182 dstport 4789 dev eth0
ip link set vxlan100 up
ip addr add 10.0.0.181/24 dev vxlan100
```

在host2执行如下命令：
```sh
ip link add vxlan100 type vxlan id 100 remote 10.128.147.181 dstport 4789 dev eth0
ip link set vxlan100 up
ip addr add 10.0.0.182/24 dev vxlan100
```

在这种模式下，通过remote分别指定了对端的vtep地址。

### configure more than 2 hosts without multicast
在底层主机不支持多播的情况下，如何配置vtep呢？

* host1: eth0, 10.128.147.181
* host2: eth0, 10.128.147.182
* host3: eth0, 10.128.147.177

在host1执行如下命令：
```sh
ip link add vxlan100 type vxlan id 100 dstport 0 dev eth0
bridge fdb append to 00:00:00:00:00:00 dst 10.128.147.182 dev vxlan100
bridge fdb append to 00:00:00:00:00:00 dst 10.128.147.177 dev vxlan100
ip addr add 192.168.200.1/24 dev vxlan100
ip link set up dev vxlan100
```

在host2执行如下命令：
```sh
ip link add vxlan100 type vxlan id 100 dstport 0 dev eth0
bridge fdb append to 00:00:00:00:00:00 dst 10.128.147.181 dev vxlan100
bridge fdb append to 00:00:00:00:00:00 dst 10.128.147.177 dev vxlan100
ip addr add 192.168.200.2/24 dev vxlan100
ip link set up dev vxlan100
```

在host3执行如下命令：
```sh
ip link add vxlan100 type vxlan id 100 dstport 0 dev eth0
bridge fdb append to 00:00:00:00:00:00 dst 10.128.147.181 dev vxlan100
bridge fdb append to 00:00:00:00:00:00 dst 10.128.147.182 dev vxlan100
ip addr add 192.168.200.3/24 dev vxlan100
ip link set up dev vxlan100
```
这种模式下通过手工维护bridge fdb表配置了任何两个host之间的vtep连接。

## 容器网络场景-大二层网络
网络架构：

![](pics/vxlan_layer2.png)

在host1执行如下命令：
```sh
ip link add vxlan100 type vxlan id 100 dstport 0 dev eth0
bridge fdb append to 00:00:00:00:00:00 dst 10.128.147.182 dev vxlan100
bridge fdb append to 00:00:00:00:00:00 dst 10.128.147.177 dev vxlan100

ip link add dev br100 type bridge
ip link set vxlan100 master br100

ip link add dev veth1001 type veth peer name veth1002
ip link set veth1001 master br100

ip netns add net100
ip link set veth1002 netns net100
ip netns exec net100 ip addr add 192.168.100.2/24 dev veth1002

ip link set up dev vxlan100
ip link set up dev br100
ip link set up dev veth1001
ip netns exec net100 ip link set veth1002 name eth0
ip netns exec net100 ip link set up dev eth0
```

在host2执行如下命令：
```sh
ip link add vxlan100 type vxlan id 100 dstport 0 dev eth0
bridge fdb append to 00:00:00:00:00:00 dst 10.128.147.181 dev vxlan100
bridge fdb append to 00:00:00:00:00:00 dst 10.128.147.177 dev vxlan100

ip link add dev br100 type bridge
ip link set vxlan100 master br100

ip link add dev veth1001 type veth peer name veth1002
ip link set veth1001 master br100

ip netns add net100
ip link set veth1002 netns net100
ip netns exec net100 ip addr add 192.168.100.3/24 dev veth1002

ip link set up dev vxlan100
ip link set up dev br100
ip link set up dev veth1001
ip netns exec net100 ip link set veth1002 name eth0
ip netns exec net100 ip link set up dev eth0
```

在host3执行如下命令：
```sh
ip link add vxlan100 type vxlan id 100 dstport 0 dev eth0
bridge fdb append to 00:00:00:00:00:00 dst 10.128.147.181 dev vxlan100
bridge fdb append to 00:00:00:00:00:00 dst 10.128.147.182 dev vxlan100

ip link add dev br100 type bridge
ip link set vxlan100 master br100

ip link add dev veth1001 type veth peer name veth1002
ip link set veth1001 master br100

ip netns add net100
ip link set veth1002 netns net100
ip netns exec net100 ip addr add 192.168.100.4/24 dev veth1002

ip link set up dev vxlan100
ip link set up dev br100
ip link set up dev veth1001
ip netns exec net100 ip link set veth1002 name eth0
ip netns exec net100 ip link set up dev eth0
```

测试：
在host1上执行如下命令，验证网络的连通性。
```sh
[root@compute3 ~]# ip netns exec net100 ping -c4 192.168.100.3
PING 192.168.100.3 (192.168.100.3) 56(84) bytes of data.
64 bytes from 192.168.100.3: icmp_seq=1 ttl=64 time=0.797 ms
64 bytes from 192.168.100.3: icmp_seq=2 ttl=64 time=0.530 ms
64 bytes from 192.168.100.3: icmp_seq=3 ttl=64 time=0.460 ms
64 bytes from 192.168.100.3: icmp_seq=4 ttl=64 time=0.552 ms

--- 192.168.100.3 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3072ms
rtt min/avg/max/mdev = 0.460/0.584/0.797/0.130 ms
[root@compute3 ~]# ip netns exec net100 ping -c4 192.168.100.4
PING 192.168.100.4 (192.168.100.4) 56(84) bytes of data.
64 bytes from 192.168.100.4: icmp_seq=1 ttl=64 time=0.334 ms
64 bytes from 192.168.100.4: icmp_seq=2 ttl=64 time=0.373 ms
64 bytes from 192.168.100.4: icmp_seq=3 ttl=64 time=0.435 ms
64 bytes from 192.168.100.4: icmp_seq=4 ttl=64 time=0.452 ms

--- 192.168.100.4 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3099ms
rtt min/avg/max/mdev = 0.334/0.398/0.452/0.051 ms

```
### 总结
VxLan是在三层网络上构建二层网络，即L2 Over L3。
以上所有的容器都在一个二层网络里面。

VxLan的好处是不需要Underlay网络是一个二层网络。VLAN则需要Underlay网络是一个二层网络。

VxLan和VLAN都可以进行二层隔离。

以上方案也就是Bridge+VxLan模式实现的容器网络跨主机通信。

同理如果底层网络是二层网络，即ethernet fabric，把VxLan换成Vlan也是可以的。

## 容器网络场景-三层网络
网络架构：

![](pics/vxlan_layer3.png)

在host1执行如下命令：
```sh
ip link add vxlan100 type vxlan id 100 dstport 0 dev eth0
bridge fdb append to 00:00:00:00:00:00 dst 10.128.147.182 dev vxlan100
bridge fdb append to 00:00:00:00:00:00 dst 10.128.147.177 dev vxlan100
ip addr add 192.169.1.0/32 dev vxlan100
ip link set up dev vxlan100
ip route add 192.169.2.0/32 dev vxlan100
ip route add 192.169.3.0/32 dev vxlan100

ip link add dev br100 type bridge
ip addr add 192.169.1.1/24 dev br100

ip link add dev veth1001 type veth peer name veth1002
ip link set veth1001 master br100

ip netns add net100
ip link set veth1002 netns net100
ip netns exec net100 ip addr add 192.169.1.2/24 dev veth1002

ip link set up dev br100
ip link set up dev veth1001
ip netns exec net100 ip link set veth1002 name eth0
ip netns exec net100 ip link set up dev eth0

ip netns exec net100 ip route add default via 192.169.1.1 dev eth0

ip route add 192.169.1.0/24 dev br100
ip route add 192.169.2.0/24 via 192.169.2.0 dev vxlan100
ip route add 192.169.3.0/24 via 192.169.3.0 dev vxlan100

iptables -t filter -A FORWARD -s 192.169.0.0/16 -j ACCEPT
iptables -t filter -A FORWARD -d 192.169.0.0/16 -j ACCEPT
```

在host2执行如下命令：
```sh
ip link add vxlan100 type vxlan id 100 dstport 0 dev eth0
bridge fdb append to 00:00:00:00:00:00 dst 10.128.147.181 dev vxlan100
bridge fdb append to 00:00:00:00:00:00 dst 10.128.147.177 dev vxlan100
ip addr add 192.169.2.0/32 dev vxlan100
ip link set up dev vxlan100
ip route add 192.169.1.0/32 dev vxlan100
ip route add 192.169.3.0/32 dev vxlan100

ip link add dev br100 type bridge
ip addr add 192.169.2.1/24 dev br100

ip link add dev veth1001 type veth peer name veth1002
ip link set veth1001 master br100

ip netns add net100
ip link set veth1002 netns net100
ip netns exec net100 ip addr add 192.169.2.2/24 dev veth1002

ip link set up dev br100
ip link set up dev veth1001
ip netns exec net100 ip link set veth1002 name eth0
ip netns exec net100 ip link set up dev eth0

ip netns exec net100 ip route add default via 192.169.2.1 dev eth0

ip route add 192.169.2.0/24 dev br100
ip route add 192.169.1.0/24 via 192.169.1.0 dev vxlan100
ip route add 192.169.3.0/24 via 192.169.3.0 dev vxlan100

iptables -t filter -A FORWARD -s 192.169.0.0/16 -j ACCEPT
iptables -t filter -A FORWARD -d 192.169.0.0/16 -j ACCEPT
```

在host3执行如下命令：
```sh
ip link add vxlan100 type vxlan id 100 dstport 0 dev eth0
bridge fdb append to 00:00:00:00:00:00 dst 10.128.147.181 dev vxlan100
bridge fdb append to 00:00:00:00:00:00 dst 10.128.147.182 dev vxlan100
ip addr add 192.169.3.0/32 dev vxlan100
ip link set up dev vxlan100
ip route add 192.169.1.0/32 dev vxlan100
ip route add 192.169.2.0/32 dev vxlan100

ip link add dev br100 type bridge
ip addr add 192.169.3.1/24 dev br100

ip link add dev veth1001 type veth peer name veth1002
ip link set veth1001 master br100

ip netns add net100
ip link set veth1002 netns net100
ip netns exec net100 ip addr add 192.169.3.2/24 dev veth1002

ip link set up dev br100
ip link set up dev veth1001
ip netns exec net100 ip link set veth1002 name eth0
ip netns exec net100 ip link set up dev eth0

ip netns exec net100 ip route add default via 192.169.3.1 dev eth0

ip route add 192.169.3.0/24 dev br100
ip route add 192.169.1.0/24 via 192.169.1.0 dev vxlan100
ip route add 192.169.2.0/24 via 192.169.2.0 dev vxlan100

iptables -t filter -A FORWARD -s 192.169.0.0/16 -j ACCEPT
iptables -t filter -A FORWARD -d 192.169.0.0/16 -j ACCEPT
```

验证网络联通性
```sh
[root@compute3 ~]# ip netns exec net100 ping -c4 192.169.2.2
PING 192.169.2.2 (192.169.2.2) 56(84) bytes of data.
64 bytes from 192.169.2.2: icmp_seq=1 ttl=62 time=0.816 ms
64 bytes from 192.169.2.2: icmp_seq=2 ttl=62 time=0.486 ms
64 bytes from 192.169.2.2: icmp_seq=3 ttl=62 time=0.580 ms
64 bytes from 192.169.2.2: icmp_seq=4 ttl=62 time=0.543 ms

--- 192.169.2.2 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3068ms
rtt min/avg/max/mdev = 0.486/0.606/0.816/0.126 ms
[root@compute3 ~]# ip netns exec net100 ping -c4 192.169.3.2
PING 192.169.3.2 (192.169.3.2) 56(84) bytes of data.
64 bytes from 192.169.3.2: icmp_seq=1 ttl=62 time=0.489 ms
64 bytes from 192.169.3.2: icmp_seq=2 ttl=62 time=0.418 ms
64 bytes from 192.169.3.2: icmp_seq=3 ttl=62 time=0.409 ms
64 bytes from 192.169.3.2: icmp_seq=4 ttl=62 time=0.381 ms

--- 192.169.3.2 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3095ms
rtt min/avg/max/mdev = 0.381/0.424/0.489/0.042 ms

```
