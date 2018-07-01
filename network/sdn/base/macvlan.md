# Macvlan简单实践
## 环境说明
VirtualBox虚拟机，Centos 7.2。
```sh
uname -r
3.10.0-862.el7.x86_64
```
0. 检查内核是否支持macvlan
```sh
modprobe macvlan
lsmod | grep macvlan
macvlan                19239  0 
```
如果第一个命令报错，或者第二个命令没有返回，则说明当前系统不支持macvlan，需要升级系统或者升级内核。
1. 增加一个intnet类型的网卡，并开启混杂模式。
```
ip link set enp0s9 promisc on
```
查看网卡状态
```
4: enp0s9: <BROADCAST,MULTICAST,PROMISC,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mode DEFAULT group default qlen 1000
    link/ether 08:00:27:d1:61:81 brd ff:ff:ff:ff:ff:ff
```
## 创建macvlan网络
以下将按照下图构建网络
![](pics/macvlan1.png)
1. 创建两个命名空间
```sh
ip netns add net1
ip netns add net2
```
2. 创建两个macvlan虚拟设备
```sh
ip link add link enp0s9 macv1 type macvlan mode bridge
ip link add link enp0s9 macv2 type macvlan mode bridge
```

3. 将设备分别加入net1和net2
```
ip link set macv1 netns net1
ip link set macv2 netns net2
```

4. 为macvlan设备配置ip
```sh
ip netns exec net1 ip addr add 192.168.100.2/24 dev macv1
ip netns exec net2 ip addr add 192.168.100.3/24 dev macv2
```
5. 开启macvlan设备
```sh
ip netns exec net1 ip link set macv1 up
ip netns exec net2 ip link set macv2 up
```

6. 分别查看设备
```sh
# ip netns exec net1 ip a
1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
6: macv1@if4: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN group default qlen 1000
    link/ether ee:a6:31:31:97:bd brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 192.168.100.2/24 scope global macv1
       valid_lft forever preferred_lft forever
    inet6 fe80::eca6:31ff:fe31:97bd/64 scope link 
       valid_lft forever preferred_lft forever

# ip netns exec net2 ip a
1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
7: macv2@if4: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN group default qlen 1000
    link/ether f2:36:e5:c7:41:27 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 192.168.100.3/24 scope global macv2
       valid_lft forever preferred_lft forever
    inet6 fe80::f036:e5ff:fec7:4127/64 scope link 
       valid_lft forever preferred_lft forever
```

## 测试连通性
从net1中的macv1 ping net2中的macv2-192.168.100.3：
```sh
# ip netns exec net1 ping 192.168.100.3
PING 192.168.100.3 (192.168.100.3) 56(84) bytes of data.
64 bytes from 192.168.100.3: icmp_seq=1 ttl=64 time=0.297 ms
64 bytes from 192.168.100.3: icmp_seq=2 ttl=64 time=0.092 ms
64 bytes from 192.168.100.3: icmp_seq=3 ttl=64 time=0.096 ms
```
从net2中的macv2 ping net1中的macv1-192.168.100.2：
```sh
# ip netns exec net2 ping 192.168.100.2
PING 192.168.100.2 (192.168.100.2) 56(84) bytes of data.
64 bytes from 192.168.100.2: icmp_seq=1 ttl=64 time=0.052 ms
64 bytes from 192.168.100.2: icmp_seq=2 ttl=64 time=0.199 ms
64 bytes from 192.168.100.2: icmp_seq=3 ttl=64 time=0.095 ms
```