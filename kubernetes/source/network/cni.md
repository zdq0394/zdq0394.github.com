# CNI
本部分属于[containernetworking/cni](https://github.com/containernetworking/cni)。

Kubelet的`cniNetworkPlugin`通过如下的CNI接口调用与具体的网络机制交互。

## CNI接口定义
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

// CNIConfig implements the CNI interface
var _ CNI = &CNIConfig{}
```

## 添加网络
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
## 删除网络
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