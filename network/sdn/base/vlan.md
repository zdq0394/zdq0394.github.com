# Linux Vlan简单实践
## VLAN基本概念
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
## 实践
ip link add enp0s9.100 link enp0s9 type vlan id 100
ip link add enp0s9.200 link enp0s9 type vlan id 200

ip netns add net100
ip netns add net200

ip link add dev br100 type bridge
ip link add dev  veth101 type veth peer name veth102
ip link set veth101 master br100
ip link set veth102 netns net100
ip netns exec net100 ip addr add 192.168.100.2/24 dev veth102
ip link set br100 up
ip link set veth101 up
ip netns exec net100 ip link set veth102 up

ip link add dev br200 type bridge
ip link add dev  veth201 type veth peer name veth202
ip link set veth201 master br200
ip link set veth202 netns net200
ip netns exec net200 ip addr add 192.168.200.2/24 dev veth202
ip link set br200 up
ip link set veth201 up
ip netns exec net200 ip link set veth202 up

ip netns add routerns

ip link add dev r101 type veth peer name r102
ip link set r101 master br100
ip link set r102 netns routerns
ip netns exec routerns ip addr add 192.168.100.1/24 dev r102

ip link add dev r201 type  veth peer name r202
ip link set r201 master br200
ip link set r202 netns routerns
ip netns exec routerns ip addr add 192.168.200.1/24 dev r202

ip link set r101 up
ip netns exec routerns ip link set r102 up

ip link set r201 up
ip netns exec routerns ip link set r202 up

ip netns exec net100 ip route add default via 192.168.100.1 dev veth102

ip netns exec net200 ip route add default via 192.168.200.1 dev veth202
