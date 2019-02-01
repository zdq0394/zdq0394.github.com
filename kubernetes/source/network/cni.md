# cniNetworkPlugin分析
## 基本定义
dockerservice通过networkpluginmanager来管理网络。
networkpluginmanager是networkplugin的一个包装类，具体功能都由networkplugin实现。

cniNetworkPlugin是networkplugin的一个实现类。
代码在kubelet/dockershim/network/cni包中。
```go
type cniNetworkPlugin struct {
	network.NoopNetworkPlugin

	loNetwork *cniNetwork

	sync.RWMutex
	defaultNetwork *cniNetwork

	host        network.Host
	execer      utilexec.Interface
	nsenterPath string
	confDir     string
	binDirs     []string
	podCidr     string
}

type cniNetwork struct {
	name          string
	NetworkConfig *libcni.NetworkConfigList
	CNIConfig     libcni.CNI
}

```
cniNetworkPlugin里面定义了2个cniNetwork：
1. loNetwork，主要是在linux系统的环回接口。
2. defaultNetwork，真正的cni网络接口，比如calico网络。

cniNetwork的属性CNIConfig，包含了具体网络实现的插件二进制，并提供了标准的接口：
```go
type CNI interface {
	AddNetworkList(net *NetworkConfigList, rt *RuntimeConf) (types.Result, error)
	DelNetworkList(net *NetworkConfigList, rt *RuntimeConf) error

	AddNetwork(net *NetworkConfig, rt *RuntimeConf) (types.Result, error)
	DelNetwork(net *NetworkConfig, rt *RuntimeConf) error
}

type CNIConfig struct {
	Path []string
}

// CNIConfig implements the CNI interface
var _ CNI = &CNIConfig{}
```


## cniNetworkPlugin的实例化
cniNetworkPlugin的实例化是在dockerservice(kubelet/dockershim/docker_service.go)中进行的。
```go
cniPlugins := cni.ProbeNetworkPlugins(pluginSettings.PluginConfDir, pluginSettings.PluginBinDirs)
```
ProbeNetworkPlugin通过syncNetworkConfig加载配置的cni插件，返回一个cniNetworkPlugin实例。

## 主要方法：
### SetUpPod
SetUpPod方法调用plugin.addToNetwork将当前容器加入到某个网络。

在addToNetwork中，会生成runtimeConf和netConf参数，调用cni插件的标准接口:AddNetworkList。

```go
func (plugin *cniNetworkPlugin) addToNetwork(network *cniNetwork, podName string, podNamespace string, podSandboxID kubecontainer.ContainerID, podNetnsPath string, annotations, options map[string]string) (cnitypes.Result, error) {
	rt, err := plugin.buildCNIRuntimeConf(podName, podNamespace, podSandboxID, podNetnsPath, annotations, options)
	....
	netConf, cniNet := network.NetworkConfig, network.CNIConfig
	....
	res, err := cniNet.AddNetworkList(netConf, rt)
	....
}
```

### TearDownPod
TearDownPod方法调用plugin.deleteFromNetwork将当前容器从某个网络中删除。
在deleteFromNetwork中，会生成runtimeConf和netConf参数，调用cni插件的标准接口:DelNetworkList。
```go
func (plugin *cniNetworkPlugin) deleteFromNetwork(network *cniNetwork, podName string, podNamespace string, podSandboxID kubecontainer.ContainerID, podNetnsPath string, annotations map[string]string) error {
	rt, err := plugin.buildCNIRuntimeConf(podName, podNamespace, podSandboxID, podNetnsPath, annotations, nil)
	....
	netConf, cniNet := network.NetworkConfig, network.CNIConfig
	....
	err = cniNet.DelNetworkList(netConf, rt)
	....
}
```

