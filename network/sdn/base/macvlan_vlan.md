# Vlan+Macvlan多租户网络
## 环境说明
VirtualBox虚拟机，Centos 7.2。
```sh
uname -r
3.10.0-862.el7.x86_64
```
安装bridge-utils软件包，并加载bridge模块和开启内核转发。
```sh
apt-get install bridge-utils
modprobe bridge

echo "1">/proc/sys/net/ipv4/ip_forward

cat /proc/sys/net/ipv4/ip_forward
1
```
## 构建网络
本文按照如下图构建网络
![](pics/vlan_macvlan.png)
### 创建主干网络
本部分在现实中都是物理网络。
```sh
ip link add dev br0 type bridge
ip link add dev v101 type veth peer name v102
ip link add dev v201 type veth peer name v202
```
### 创建主机网络（左）
主机网络分为两个vlan
```sh
ip link add link v102 dev v102.100 type vlan id 100
ip link set dev v102.100 promisc on
ip link add link v102 dev v102.200 type vlan id 200
ip link set dev v102.200 promisc on
```
### 创建容器网络
```sh
ip link add link v102.100 dev v102.100.m1 type macvlan mode bridge
ip link add link v102.100 dev v102.100.m2 type macvlan mode bridge
ip link add link v102.200 dev v102.200.m1 type macvlan mode bridge
ip link add link v102.200 dev v102.200.m2 type macvlan mode bridge

ip netns add pod11
ip netns add pod12
ip netns add pod13
ip netns add pod14

ip link set dev v102.100.m1 netns pod11
ip link set dev v102.100.m2 netns pod12
ip link set dev v102.200.m1 netns pod13
ip link set dev v102.200.m2 netns pod14

ip netns exec pod11 ip addr add 192.168.100.101/24 dev v102.100.m1
ip netns exec pod12 ip addr add 192.168.100.102/24 dev v102.100.m2
ip netns exec pod13 ip addr add 192.168.100.103/24 dev v102.200.m1
ip netns exec pod14 ip addr add 192.168.100.104/24 dev v102.200.m2
```
### 开启所有设备
```sh
ip netns exec pod11 ip link set dev v102.100.m1 up
ip netns exec pod12 ip link set dev v102.100.m2 up
ip netns exec pod13 ip link set dev v102.200.m1 up
ip netns exec pod14 ip link set dev v102.200.m2 up

ip link set dev v102.100 up
ip link set dev v102.200 up

ip link set dev v102 up
ip link set dev v101 up
```

### 创建主机网络
主机网络分为两个vlan
```sh
ip link add link v202 dev v202.100 type vlan id 100
ip link set dev v202.100 promisc on
ip link add link v202 dev v202.200 type vlan id 200
ip link set dev v202.200 promisc on
```
### 创建容器网络
```
ip link add link v202.100 dev v202.100.m1 type macvlan mode bridge
ip link add link v202.100 dev v202.100.m2 type macvlan mode bridge
ip link add link v202.200 dev v202.200.m1 type macvlan mode bridge
ip link add link v202.200 dev v202.200.m2 type macvlan mode bridge

ip netns add pod21
ip netns add pod22
ip netns add pod23
ip netns add pod24

ip link set dev v202.100.m1 netns pod21
ip link set dev v202.100.m2 netns pod22
ip link set dev v202.200.m1 netns pod23
ip link set dev v202.200.m2 netns pod24

ip netns exec pod21 ip addr add 192.168.100.201/24 dev v202.100.m1
ip netns exec pod22 ip addr add 192.168.100.202/24 dev v202.100.m2
ip netns exec pod23 ip addr add 192.168.100.203/24 dev v202.200.m1
ip netns exec pod24 ip addr add 192.168.100.204/24 dev v202.200.m2
```
开启所有设备
```sh
ip netns exec pod21 ip link set dev v202.100.m1 up
ip netns exec pod22 ip link set dev v202.100.m2 up
ip netns exec pod23 ip link set dev v202.200.m1 up
ip netns exec pod24 ip link set dev v202.200.m2 up

ip link set dev v202.100 up
ip link set dev v202.200 up

ip link set dev v202 up
ip link set dev v201 up
```
### 主机网络联通
```sh
ip link set dev v101 master br0
ip link set dev v201 master br0
ip link set dev v101 up
ip link set dev v201 up
ip link set br0 up
```
