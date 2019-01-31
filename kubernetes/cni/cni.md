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