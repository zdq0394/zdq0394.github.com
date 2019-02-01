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


## cniNetworkPlugin
源码kubelet/dockershim/network/cni/cni.go中`cniNetworkPlugin`包括两个主要方法：
1. SetUpPod
```go
func (plugin *cniNetworkPlugin) SetUpPod(namespace string, name string, id kubecontainer.ContainerID, annotations, options map[string]string) error
```
2. TearDownPod
```go
func (plugin *cniNetworkPlugin) TearDownPod(namespace string, name string, id kubecontainer.ContainerID) error
```