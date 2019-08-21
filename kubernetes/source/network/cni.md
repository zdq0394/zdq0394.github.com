# Container Network Interface
本部分属于[containernetworking/cni](https://github.com/containernetworking/cni)和[containernetworking/plugins](https://github.com/containernetworking/plugins)两个部分。
## cni
CNI主要内容包括两个部分：
* libcni：主要实现了cniNetworkPlugin调用CNI框架时的入口API；libcni封装合适的配置和参数调用具体的网络二进制代码，比如calico,ipam,portmap等。
* pkg：提供了具体网络机制需要使用的骨架代码。所有的网络机制插件实现，比如calico,ipam,portmap等都要基于此实现。
### libcni
#### CNI接口
Kubelet的`cniNetworkPlugin`通过如下的CNI接口调用与具体的网络机制交互。
```go
type CNI interface {
	AddNetworkList(ctx context.Context, net *NetworkConfigList, rt *RuntimeConf) (types.Result, error)
	CheckNetworkList(ctx context.Context, net *NetworkConfigList, rt *RuntimeConf) error
	DelNetworkList(ctx context.Context, net *NetworkConfigList, rt *RuntimeConf) error

	AddNetwork(ctx context.Context, net *NetworkConfig, rt *RuntimeConf) (types.Result, error)
	CheckNetwork(ctx context.Context, net *NetworkConfig, rt *RuntimeConf) error
	DelNetwork(ctx context.Context, net *NetworkConfig, rt *RuntimeConf) error
	GetNetworkCachedResult(net *NetworkConfig, rt *RuntimeConf) (types.Result, error)

	ValidateNetworkList(ctx context.Context, net *NetworkConfigList) ([]string, error)
	ValidateNetwork(ctx context.Context, net *NetworkConfig) ([]string, error)
}
```

CNIConfig是CNI的一个具体实现类。

```go
type CNIConfig struct {
	Path []string
	exec invoke.Exec
}
var _ CNI = &CNIConfig{}
```

#### 添加网络
```go
func (c *CNIConfig) addNetwork(ctx context.Context, name, cniVersion string, net *NetworkConfig, prevResult types.Result, rt *RuntimeConf) (types.Result, error) {
	c.ensureExec()
	pluginPath, err := c.exec.FindInPath(net.Network.Type, c.Path)
	if err != nil {
		return nil, err
	}

	newConf, err := buildOneConfig(name, cniVersion, net, prevResult, rt)
	if err != nil {
		return nil, err
	}

	return invoke.ExecPluginWithResult(ctx, pluginPath, newConf.Bytes, c.args("ADD", rt), c.exec)
}
```
添加网络会通过二进制引擎调用具体插件的二进制文件，并提供"ADD"动作。
#### 删除网络
```go
func (c *CNIConfig) delNetwork(ctx context.Context, name, cniVersion string, net *NetworkConfig, prevResult types.Result, rt *RuntimeConf) error {
	c.ensureExec()
	pluginPath, err := c.exec.FindInPath(net.Network.Type, c.Path)
	if err != nil {
		return err
	}

	newConf, err := buildOneConfig(name, cniVersion, net, prevResult, rt)
	if err != nil {
		return err
	}

	return invoke.ExecPluginWithoutResult(ctx, pluginPath, newConf.Bytes, c.args("DEL", rt), c.exec)
}
```
删除网络会通过二进制引擎调用具体插件的二进制文件，并提供"DEL"动作。

### 基础/公共组件
pkg提供了具体网络机制需要使用的骨架代码。
[containernetworking/plugins](https://github.com/containernetworking/plugins)中的各种类型的plugin都基于该骨架实现。

## plugins
plugins包括main、meta和ipam几种大类。
* main：具体的网络方案，比如vlan、ipvlan、bridge等。
* ipam：如何分配ip地址，配置路由表及dns等。
* meta：主要实现一些网络相关功能：比如portmap、bandwidth等。

如果要实现自己的网络方案，比如calico，那要实现自己的main/ipam插件，对于calico就是`calico`和`calico-ipam`。
### ipam
cni官方实现了3个ipam的plugin：
* static
* host-local
* dhcp
#### static
静态ip地址分配生产环境中不常用。一般用来
1. 调试方便
2. 给不同vlan/vxlan网络中的容器分配同样的ip地址

#### host-local
顾名思义，`host-local` ip地址分配，每个宿主机host节点分配一个或者多个ip range，各个host的ip range不重复。`host`通过本地文件系统管理ip ranges的状态，自己负责该host上的容器的ip地址的唯一性。

`host-local`中`ranges`的数量决定了ip地址的个数——可以分配多个ip地址。
每个range里可以有多个subnet，各个subnet通过round-robin的方式提供ip地址。

`host-local`可以指定custom-ip。当然custom-ip必须在host-local的范围之内，并且未在使用。

#### dhcp
如果网络里面已经运行dhcp daemon进程，那么可以使用dhcp模式来分配IP。

### meta
cni官方实现了4个meta的plugin：
* bandwidth
* portmap
* flannel
* tuning
#### bandwidth
`Bandwith`插件通过Linux's Traffic control (tc) 子系统配置网络接口，实现网络整形shape。

```json
    {
      "name": "slowdown",
      "type": "bandwidth",
      "ingressRate": 123,
      "ingressBurst": 456,
      "egressRate": 123,
      "egressBurst": 456
    }
```
#### portmap
`portmap`插件实现了将宿主机host上的一个或者多个端口转发到container port。
用来实现`HostPort`功能。

#### tuning
`tuning`插件可以用来配置interface的sysctls，如下：

```
{
  "name": "mytuning",
  "type": "tuning",
  "sysctl": {
          "net.core.somaxconn": "500"
  }
}
```
将设置`/proc/sys/net/core/somaxconn to 500`。

也可以设置interface的一些属性：

```
{
  "name": "mytuning",
  "type": "tuning",
  "promisc": true,
  "mac": "c2:b0:57:49:47:f1",
  "mtu": 1454
}
```

#### flannel
`flannel`插件配合网络机制`flannel`。