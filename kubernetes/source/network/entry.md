# 网络调用入口
网络流程入口部分在kubelet源码中。由于网络部分相对独立，我们也独立分析。
## 运行时
网络流程是由运行时调用的。这里以docker(dockershim)为例。
dockerservice通过networkpluginmanager来管理网络。
代码在kubelet/dockershim/docker_service.go中
### 初始化networkpluginmanager
dockerservice包含的属性，其中network是指networkpluginmanager。
```go

type dockerService struct {
	client           libdocker.Interface
	os               kubecontainer.OSInterface
	podSandboxImage  string
	streamingRuntime *streamingRuntime
	streamingServer  streaming.Server

	network *network.PluginManager
	// Map of podSandboxID :: network-is-ready
	networkReady     map[string]bool
	networkReadyLock sync.Mutex

	containerManager cm.ContainerManager
	// cgroup driver used by Docker runtime.
	cgroupDriver      string
	checkpointManager checkpointmanager.CheckpointManager
	// caches the version of the runtime.
	// To be compatible with multiple docker versions, we need to perform
	// version checking for some operations. Use this cache to avoid querying
	// the docker daemon every time we need to do such checks.
	versionCache *cache.ObjectCache
	// startLocalStreamingServer indicates whether dockershim should start a
	// streaming server on localhost.
	startLocalStreamingServer bool
}
```
在dockerservice实例化时，会同时初始化networkpluginmanager，并且networkpluginmanager中真正使用的cniNetworkPlugin。
```go
	// dockershim currently only supports CNI plugins.
	pluginSettings.PluginBinDirs = cni.SplitDirs(pluginSettings.PluginBinDirString)
	cniPlugins := cni.ProbeNetworkPlugins(pluginSettings.PluginConfDir, pluginSettings.PluginBinDirs)
	cniPlugins = append(cniPlugins, kubenet.NewPlugin(pluginSettings.PluginBinDirs))
	netHost := &dockerNetworkHost{
		&namespaceGetter{ds},
		&portMappingGetter{ds},
	}
	plug, err := network.InitNetworkPlugin(cniPlugins, pluginSettings.PluginName, netHost, pluginSettings.HairpinMode, pluginSettings.NonMasqueradeCIDR, pluginSettings.MTU)
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
当然，都是通过调用networkplugin实现的。
```go
func (pm *PluginManager) SetUpPod(podNamespace, podName string, id kubecontainer.ContainerID, annotations, options map[string]string) error
func (pm *PluginManager) TearDownPod(podNamespace, podName string, id kubecontainer.ContainerID) error 
```

networkplugin定义了如下接口：
```go
// Plugin is an interface to network plugins for the kubelet
type NetworkPlugin interface {
	// Init initializes the plugin.  This will be called exactly once
	// before any other methods are called.
	Init(host Host, hairpinMode kubeletconfig.HairpinMode, nonMasqueradeCIDR string, mtu int) error

	// Called on various events like:
	// NET_PLUGIN_EVENT_POD_CIDR_CHANGE
	Event(name string, details map[string]interface{})

	// Name returns the plugin's name. This will be used when searching
	// for a plugin by name, e.g.
	Name() string

	// Returns a set of NET_PLUGIN_CAPABILITY_*
	Capabilities() utilsets.Int

	// SetUpPod is the method called after the infra container of
	// the pod has been created but before the other containers of the
	// pod are launched.
	SetUpPod(namespace string, name string, podSandboxID kubecontainer.ContainerID, annotations, options map[string]string) error

	// TearDownPod is the method called before a pod's infra container will be deleted
	TearDownPod(namespace string, name string, podSandboxID kubecontainer.ContainerID) error

	// GetPodNetworkStatus is the method called to obtain the ipv4 or ipv6 addresses of the container
	GetPodNetworkStatus(namespace string, name string, podSandboxID kubecontainer.ContainerID) (*PodNetworkStatus, error)

	// Status returns error if the network plugin is in error state
	Status() error
}
```

