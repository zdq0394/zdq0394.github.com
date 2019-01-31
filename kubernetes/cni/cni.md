# CNI-Container Network Interface
## 概述
CNI（Container Network Interface）是CNCF旗下的一个项目，由一组用于配置Linux容器的网络接口的规范和库组成，同时还包含了一些插件。
CNI仅关心当容器创建时的网络资源分配和当容器被删除时的网络资源释放。
## 接口定义
CNI定义了如下几个接口：
```go
type CNI interface {
    AddNetworkList(net *NetworkConfigList, rt *RuntimeConf) (types.Result, error)
    DelNetworkList(net *NetworkConfigList, rt *RuntimeConf) error

    AddNetwork(net *NetworkConfig, rt *RuntimeConf) (types.Result, error)
    DelNetwork(net *NetworkConfig, rt *RuntimeConf) error
}
```
## 设计原则
* 容器运行时必须在调用任何插件之前为容器创建一个新的网络命名空间。
* 然后，运行时必须确定这个容器应属于哪个网络，并为每个网络确定哪些插件必须被执行。
* 网络配置采用JSON格式，可以很容易地存储在文件中。网络配置包括必填字段，如name和type以及插件（类型）。网络配置允许字段在调用之间改变值。为此，有一个可选的字段args，必须包含不同的信息。
* 容器运行时必须按顺序为每个网络执行相应的插件，将容器添加到每个网络中。
* 在完成容器生命周期后，运行时必须以相反的顺序执行插件（相对于执行添加容器的顺序）以将容器与网络断开连接。
* 容器运行时不能为同一容器调用并行操作，但可以为不同的容器调用并行操作。
* 容器运行时必须为容器订阅ADD和DEL操作，这样ADD后面总是跟着相应的DEL。 DEL可能跟着额外的DEL，但是，插件应该允许处理多个DEL（即插件DEL应该是幂等的）。
* 容器必须由ContainerID唯一标识。存储状态的插件应该使用（网络名称，容器ID）的主键来完成。
* 运行时不能调用同一个网络名称或容器ID执行两次ADD（没有相应的DEL）。换句话说，给定的容器ID必须只能添加到特定的网络一次。

## CNI插件
CNI插件必须实现为一个可执行文件，这个文件可以被容器管理系统（例如rkt或Kubernetes）调用。

CNI插件负责将网络接口插入`容器网络命名空间`（例如，veth对的一端），并在主机上进行任何必要的配置（例如将veth的另一端连接到网桥）。然后通过IPAM插件给接口分配IP，并设置必要的路由。

## IP分配
作为容器网络管理的一部分，CNI插件需要为接口分配（并维护）IP地址，并安装与该接口相关的所有必要路由。CNI主插件通过调用`IPAM插件`来实现。

IPAM插件必须确定接口IP/subnet，网关和路由，并将此信息返回到“主”插件来应用配置。
CNI主插件的职责是在执行时恰当地调用IPAM插件。

### IPAM插件
如同CNI插件一样，IPAM插件也是实现为一个可执行文件。
可执行文件位于预定义的路径列表中，通过CNI_PATH指示给CNI插件。
IPAM插件必须接收所有传入CNI插件的相同环境变量。
就像CNI插件一样，IPAM插件通过stdin接收网络配置。

## 可用插件
### Main：接口创建
* bridge：创建网桥，并添加主机和容器到该网桥
* ipvlan：在容器中添加一个ipvlan接口
* loopback：创建一个回环接口
* macvlan：创建一个新的MAC地址，将所有的流量转发到容器
* ptp：创建veth对
* vlan：分配一个vlan设备

### IPAM：IP地址分配
* dhcp：在主机上运行守护程序，代表容器发出DHCP请求
* host-local：维护分配IP的本地数据库

### Meta：其它插件
* flannel：根据flannel的配置文件创建接口
* tuning：调整现有接口的sysctl参数
* portmap：一个基于iptables的portmapping插件。将端口从主机的地址空间映射到容器。

## 参考
* https://jimmysong.io/kubernetes-handbook/concepts/cni.html