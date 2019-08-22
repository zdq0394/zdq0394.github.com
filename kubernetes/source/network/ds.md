# cni中的数据结构
每当将一个pod加入到一个网络时，就要对对应的cni-plugin进行一次调用（one invocation of a CNI plugin）。调用时要提供一定的arguments，这就是：
* RuntimeConf 调用需要的参数，当然这些参数不包括网络本身的配置部分，主要是指容器的ID、网络的namespace等
* NetConfigList 提供network fabric的网络的配置信息。
## RuntimeConf
RuntimeConf主要包含了本次要加入网络的endpoint的信息。主要信息包括：
* ContainerID
* NetNS
* IfName
* Args
源码如下：
```go
type RuntimeConf struct {
	ContainerID string
	NetNS       string
	IfName      string
	Args        [][2]string
	CapabilityArgs map[string]interface{}
	CacheDir string
}
```

## NetworkConfigList
`NetworkConfigList`是`NetworkConfig`的列表（slice）。
而NetworkConfig是NetConf的封装，NetworkConfig就是`NetConf和NetConf的二进制字节序列`。
NetworkConfigList包含了NetworkConfig的列表，而其中的Bytes字节序列是`NetConfList的二进制字节序列`。

注意4个数据结构之间的关系：
* NetConf
* NetConfList
* NetworkConfig
* NetworkConfigList

注：字节序列包含NetConf之外的东西，比如runtimeConfig
```go
type NetworkConfig struct {
	Network *types.NetConf
	Bytes   []byte
}

type NetworkConfigList struct {
	Name         string
	CNIVersion   string
	DisableCheck bool
	Plugins      []*NetworkConfig
	Bytes        []byte
}
```

## True Value
前面讲述调用网络插件的时候提到下面两点：
* NetworkConfig作为stdin数据传入
* RuntimeConf作为ENV数据传入

其实不完全这样，查看代码
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

真正传入stdin的data是3部分儿来：
* NetworkConfig
* runtimeConf中提供的network支持的capabilities
* 之前插件执行结果
```go
newConf, err := buildOneConfig(name, cniVersion, net, prevResult, rt)
```

