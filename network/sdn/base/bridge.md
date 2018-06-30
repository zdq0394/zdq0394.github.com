# Bridge简单实践
## 基本概念
网桥bridge是一个**虚拟网络设备**，具有网络设备的特性：可以配置IP、MAC地址等；
而且，bridge还是一个**虚拟交换机**，和物理交换机设备功能类似。

网桥是一种在**链路层实现中继**，对帧进行转发的技术，根据MAC分区块，可隔离碰撞，将网络的多个网段在数据链路层连接起来的网络设备。

* 对于普通的物理设备来说，只有两端，从一端进来的数据会从另一端出去。比如物理网卡，从外面网络中收到的数据会转发到内核协议栈中，而从协议栈过来的数据会转发到外面的物理网络中。
* 而bridge不同，bridge有多个端口，数据可以从任何端口进来，进来之后从哪个口出去需要看mac地址，原理与物理交换机类似。 

网桥bridge是建立在**从设备上**——所谓从设备，如物理设备、虚拟设备、vlan设备等，即attach一个从设备，类似于现实世界中的交换机和一个用户终端之间连接了一根网线。并且可以为bridge配置一个IP，这样该主机就可以通过这个bridge设备与网络中的其他主机进行通信了。

另外Bridge的从设备被虚拟化为端口port，它们的IP及MAC都不再可用，且它们被设置为接受任何包，最终由bridge设备来决定数据包的去向：接收到本机、转发、丢弃、广播。
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

## brctl命令说明
```sh
brctl 
Usage: brctl [commands]
commands:
	addbr     	<bridge>		add bridge
	delbr     	<bridge>		delete bridge
	addif     	<bridge> <device>	add interface to bridge
	delif     	<bridge> <device>	delete interface from bridge
	hairpin   	<bridge> <port> {on|off}	turn hairpin on/off
	setageing 	<bridge> <time>		set ageing time
	setbridgeprio	<bridge> <prio>		set bridge priority
	setfd     	<bridge> <time>		set bridge forward delay
	sethello  	<bridge> <time>		set hello time
	setmaxage 	<bridge> <time>		set max message age
	setpathcost	<bridge> <port> <cost>	set path cost
	setportprio	<bridge> <port> <prio>	set port priority
	show      	[ <bridge> ]		show a list of bridges
	showmacs  	<bridge>		show a list of mac addrs
	showstp   	<bridge>		show bridge stp info
	stp       	<bridge> {on|off}	turn stp on/off
```

## 实践
创建一个网桥
```sh
brctl addbr br0
```
也可以通过**ip link**命令创建网桥
```sh
ip link add br1 type bridge
```
查看刚刚创建的网桥
```sh
brctl show
bridge name	bridge id		STP enabled	interfaces
br0		8000.000000000000	no		
br1		8000.000000000000	no		
docker0		8000.02423260ded2	no
```
创建两个**veth pair**
```sh
ip link add br0-veth1 type veth peer name br0-veth2
ip link add br0-veth3 type veth peer name br0-veth4
```
创建两个network namespace
```sh
ip netns add net1
ip netns add net2
```
分别将2个veth pair的奇数端加入网桥，偶数端加入net1和net2
```sh
ip link set br0-veth1 master br0
ip link set br0-veth3 master br0
ip link set br0-veth2 netns net1
ip link set br0-veth4 netns net2
```
将net1和net2中的veth配置ip并启用
```sh
ip netns exec net1 ip addr add 192.168.101.2/24 dev br0-veth2
ip netns exec net2 ip addr add 192.168.101.4/24 dev br0-veth4

ip netns exec net1 ip link set dev br0-veth2 up
ip netns exec net2 ip link set dev br0-veth4 up

```
将网桥br0和br0-veth1、bro-veth2启用
```sh
ip link set br0 up
ip link set br0-veth1 up
ip link set br0-veth3 up
```

## 测试连通性
从net1中ping net2中的ip
```sh
ip netns exec net1 ping -c 4 192.168.101.4 -I br0-veth2
PING 192.168.101.4 (192.168.101.4) from 192.168.101.2 br0-veth2: 56(84) bytes of data.
64 bytes from 192.168.101.4: icmp_seq=1 ttl=64 time=0.070 ms
64 bytes from 192.168.101.4: icmp_seq=2 ttl=64 time=0.047 ms
64 bytes from 192.168.101.4: icmp_seq=3 ttl=64 time=0.065 ms
64 bytes from 192.168.101.4: icmp_seq=4 ttl=64 time=0.080 ms
```
从net2中ping net1中的ip
```sh
ip netns exec net2 ping -c 4 192.168.101.2 -I br0-veth4
PING 192.168.101.2 (192.168.101.2) from 192.168.101.4 br0-veth4: 56(84) bytes of data.
64 bytes from 192.168.101.2: icmp_seq=1 ttl=64 time=0.068 ms
64 bytes from 192.168.101.2: icmp_seq=2 ttl=64 time=0.049 ms
64 bytes from 192.168.101.2: icmp_seq=3 ttl=64 time=0.057 ms
```