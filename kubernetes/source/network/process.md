# Kubelet调用network流程
Kubelet在提供pod时需要与网络组件交互，实现网络的功能。
## kubelet/运行时
网络的调用流程是由运行时(runtime)发起的。这里以运行时docker(dockershim)为例。dockerservice通过networkpluginmanager来管理网络。代码在kubelet/dockershim/docker_service.go中
### 初始化networkpluginmanager
dockerservice包含的属性，其中network是指networkpluginmanager。networkpluginmanager通过包含的networkplugin起作用。
```go
type dockerService struct {
	...
	network *network.PluginManager
	// Map of podSandboxID :: network-is-ready
	networkReady     map[string]bool
	networkReadyLock sync.Mutex
}
```
在dockerservice实例化时，会初始化相应的networkpluginmanager，并且networkpluginmanager中真正使用的plugin是`cniNetworkPlugin`。可以认为networkplugin/cniNetworkPlugin是kubelet和cni框架之间的适配器。
```go
	// dockershim currently only supports CNI plugins.
	pluginSettings.PluginBinDirs = cni.SplitDirs(pluginSettings.PluginBinDirString)
	cniPlugins := cni.ProbeNetworkPlugins(pluginSettings.PluginConfDir, pluginSettings.PluginBinDirs)
	cniPlugins = append(cniPlugins, kubenet.NewPlugin(pluginSettings.PluginBinDirs))
	netHost := &dockerNetworkHost{
		&namespaceGetter{ds},
		&portMappingGetter{ds},
	}
	plug, err := network.InitNetworkPlugin(cniPlugins, pluginSettings.PluginName, netHost pluginSettings.HairpinMode, pluginSettings.NonMasqueradeCIDR, pluginSettings.MTU)
	if err != nil {
		return nil, fmt.Errorf("didn't find compatible CNI plugin with given settings %+v: %v", pluginSettings, err)
	}
	ds.network = network.NewPluginManager(plug)
    klog.Infof("Docker cri networking managed by %v", plug.Name())
```
### 调用
当dockerservice创建podSandbox时会调用networkpluginmanager实现网络功能。

文件kubelet/dockershim/docker_sandbox.go
1. 加入网络
```go
func (ds *dockerService) RunPodSandbox(ctx context.Context, r *runtimeapi.RunPodSandboxRequest) (*runtimeapi.RunPodSandboxResponse, error) {
    ....
  err = ds.network.SetUpPod(config.GetMetadata().Namespace, config.GetMetadata().Name, cID, config.Annotations, networkOptions)
    ....
}
```
RunPodSandbox是CRI接口。dockerservice在该方法中通过调用network(networkpluginmanager)将pod加入网络。
2. 离开网络
```go
func (ds *dockerService) StopPodSandbox(ctx context.Context, r *runtimeapi.StopPodSandboxRequest) (*runtimeapi.StopPodSandboxResponse, error) {
    ....
    err := ds.network.TearDownPod(namespace, name, cID)
    ....
}
```
StopPodSandbox是CRI接口。dockerservice在该方法中通过调用network(networkpluginmanager)将pod离开网络。

## networkpluginmanager
networkpluginmanager逻辑相对简单，就是一个networkplugin的包装类。
kubelet/dockershim/network/plugins.go
```go
// The PluginManager wraps a kubelet network plugin and provides synchronization
// for a given pod's network operations.  Each pod's setup/teardown/status operations
// are synchronized against each other, but network operations of other pods can
// proceed in parallel.
type PluginManager struct {
	// Network plugin being wrapped
	plugin NetworkPlugin

	// Pod list and lock
	podsLock sync.Mutex
	pods     map[string]*podLock
}
```
networkpluginmanager主要实现了2个方法。
当然，都是通过委托给networkplugin实现的。
```go
func (pm *PluginManager) SetUpPod(podNamespace, podName string, id kubecontainer.ContainerID, annotations, options map[string]string) error
func (pm *PluginManager) TearDownPod(podNamespace, podName string, id kubecontainer.ContainerID) error 
```
## network plugin
`NetworkPlugin`是kubelet中的网络插件接口类。`NetworkPlugin`接口提供了如下方法，代码在kubelet/dockershim/network/plugins.go中
```go
// NetworkPlugin is an interface to network plugins for the kubelet
type NetworkPlugin interface {
	Init(host Host, hairpinMode kubeletconfig.HairpinMode, nonMasqueradeCIDR string, mtu int) error
	Event(name string, details map[string]interface{})
	Name() string
	Capabilities() utilsets.Int
	SetUpPod(namespace string, name string, podSandboxID kubecontainer.ContainerID, annotations, options map[string]string) error
	TearDownPod(namespace string, name string, podSandboxID kubecontainer.ContainerID) error
	GetPodNetworkStatus(namespace string, name string, podSandboxID kubecontainer.ContainerID) (*PodNetworkStatus, error)
	Status() error
}
```
`cniNetworkPlugin`和`kubenetNetworkPlugin`都是该接口的一个具体实现。

值得注意的是：`cniNetworkPlugin`是整个网络的一种实现策略，不是具体实现机制。`cniNetworkPlugin`通过一套out-of-tree的方式与具体的网络机制比如calico交互以实现网络功能。

## cniNetworkPlugin
`cniNetworkPlugin`是networkplugin的一个实现类。代码在kubelet/dockershim/network/cni包中。

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
`cniNetworkPlugin`包含一个`cniNetwork`类型的网络`defaultNetwork`。
`cniNetwork`包含一个具体的cni网络配置`NetworkConfig`和一个实现了`libcni.CNI`接口的CNIConfig。CNIConfig中包含具体的网络类型——比如calico，具体的网络插件执行路径`/opt/cni/bin/`。

那么什么是libcni.CNI接口呢？
## cni
### CNI接口定义
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

### cniNetworkPlugin和CNI
cniNetworkPlugin是networkplugin的一个具体实现。
它要实现包括`SetUpPod`和`TearDownPod`在内的networkplugin方法。
#### SetUpPod
SetUpPod方法调用plugin.addToNetwork将当前容器加入到某个网络。

在addToNetwork中，会生成runtimeConf和netConf参数，调用cni框架的标准接口:AddNetworkList。

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

#### TearDownPod
TearDownPod方法调用plugin.deleteFromNetwork将当前容器从某个网络中删除。
在deleteFromNetwork中，会生成runtimeConf和netConf参数，调用cni框架的标准接口:DelNetworkList。
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

从以上分析可以看出，kubelet通过调用cniNetworkPlugin来创建/删除网络，cniNetworkPlugin通过调用cni的API与cni框架交互来创建/删除网络。cniNetworkPlugin是kubelet和具体的cni网络方案——比如calico等的适配器。

#### buildCNIRuntimeConf
运行时通过方法`buildCNIRuntimeConf`构建`RuntimeConf。
```go
    rt := &libcni.RuntimeConf{
		ContainerID: podSandboxID.ID,
		NetNS:       podNetnsPath,
		IfName:      network.DefaultInterfaceName,
		CacheDir:    plugin.cacheDir,
		Args: [][2]string{
			{"IgnoreUnknown", "1"},
			{"K8S_POD_NAMESPACE", podNs},
			{"K8S_POD_NAME", podName},
			{"K8S_POD_INFRA_CONTAINER_ID", podSandboxID.ID},
		},
	}
```
* ContainerID: Pod的Sandbox容器的ID。
* NetNS: pod的net namespace path。
* IfName: 设备的名字，比如eth0。

Args包含了一些orchastrotor相关的信息：
* K8S_POD_NAMESPACE
* K8S_POD_NAME
* K8S_POD_INFRA_CONTAINER_ID

RuntimeConf中CapabilityArgs包含portmappings，bandwidth, ipRanges, dns等信息。
```go
rt.CapabilityArgs = map[string]interface{}{
		"portMappings": portMappingsParam,
}
...
rt.CapabilityArgs["bandwidth"] = bandwidthParam
...
rt.CapabilityArgs["ipRanges"] = [][]cniIPRange{{{Subnet: plugin.podCidr}}}
...
rt.CapabilityArgs["dns"] = *dnsParam
```
CapabilityArgs的参数如果NetworkConfig具体的网络支持。