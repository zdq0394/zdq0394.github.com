# Docker Based CRI分析
## kubelet/dockershim
CRI规范要求容器运行时实现两个接口规范
* RuntimeService
* ImageService
由于Docker与CRI不是兼容的，所有需要实现一个shim，类似于adapter转换器，使得docker按照CRI接口对外提供服务。

DockerServer是一个gRPC server，其IDL定义在kubelet/cri/runtime/v1alpha2中。整个dockershim模块都是对该gRPC接口的实现。

## kubelet启动dockershim server使docker支持CRI
kubelet.go的方法`NewMainKubelet`中，根据containerRuntime名称，如果不是remote的话，会启动dockershim server
```go
    switch containerRuntime {
	case kubetypes.DockerContainerRuntime:
		// Create and start the CRI shim running as a grpc server.
		streamingConfig := getStreamingConfig(kubeCfg, kubeDeps, crOptions)
		ds, err := dockershim.NewDockerService(kubeDeps.DockerClientConfig, crOptions.PodSandboxImage, streamingConfig,
			&pluginSettings, runtimeCgroups, kubeCfg.CgroupDriver, crOptions.DockershimRootDirectory, !crOptions.RedirectContainerStreaming)
        
        ....

		glog.V(2).Infof("Starting the GRPC server for the docker CRI shim.")
		server := dockerremote.NewDockerServer(remoteRuntimeEndpoint, ds)
		if err := server.Start(); err != nil {
			return nil, err
        }
```
此时，已经启动了DockerServer，按照CRI接口提供服务。
## kubelet通过CRI接口访问docker
Kubelet使用DockerServer提供的服务，需要通过gRPC Client调用，所有kubelet中又封装了一个remoteRuntimeService，封装了gRPC Client，调用远程的CRI Server。

如下代码把前面创建的docker gRPC server的监听地址`remoteRuntimeEndpoint`和`remoteImageEndpoint`作为参数构造remoteRuntimeService和remoteImageService。

```go
	runtimeService, imageService, err := getRuntimeAndImageServices(remoteRuntimeEndpoint, remoteImageEndpoint, kubeCfg.RuntimeRequestTimeout)
	if err != nil {
		return nil, err
	}
	klet.runtimeService = runtimeService
```
```go
func getRuntimeAndImageServices(remoteRuntimeEndpoint string, remoteImageEndpoint string, runtimeRequestTimeout metav1.Duration) (internalapi.RuntimeService, internalapi.ImageManagerService, error) {
	rs, err := remote.NewRemoteRuntimeService(remoteRuntimeEndpoint, runtimeRequestTimeout.Duration)
	if err != nil {
		return nil, nil, err
	}
	is, err := remote.NewRemoteImageService(remoteImageEndpoint, runtimeRequestTimeout.Duration)
	if err != nil {
		return nil, nil, err
	}
	return rs, is, err
}
```
最后，runtimeService和imageService还作为参数构造KubeGenericRuntimeManager。构造出来的KubeGenericRuntimeManager实例分别赋值给三个接口：
``` go
	klet.containerRuntime = runtime
	klet.streamingRuntime = runtime
	klet.runner = runtime
```

其实，NewKubeGenericRuntimeManager方法中，又对runtimeService和imageService进行了封装，主要是为了记录operation/error的metrics。
```
		runtimeService:      newInstrumentedRuntimeService(runtimeService),
		imageService:        newInstrumentedImageManagerService(imageService),
```




