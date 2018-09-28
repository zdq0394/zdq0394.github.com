# Kubelet
## Kubelet核心流程
* 开启，表示独立的自治组件，由单独的goroutine运行。
* 运行，由wait.util框架周期性执行的功能块。
* 生成，生成对象或者对象管理器，提供管理方法（工具方法）由外界调用执行。
kubelet的Run方法中执行了kubelet的主要流程：
* 开启logServer
* 开启cloudResourceSyncManager
* 初始化内部模块initializeModules
    * 注册prometheus metrics
    * 生成setupDataDirs
        * root directory
        * pods directory
        * plugins directory
    * 生成ContainerLogsDir
    * 开启imageManager：此处开启的是Image GC Manager。
    * 开启serverCertificateManager
    * 开启oomWatcher：OOMWatcher从cAdvisor获取`oom`事件，然后将事件Post到kubelet中。
    * 开启resourceAnalyzer：提供node资源的消费汇总数据。
        * fsResourceAnalyzer
        * summaryProvider
* 开启volumeManager
* 运行syncNodeStatus
    * registerWithAPIServer
    * updateNodeStatus
* 运行nodeLeaseController
* 运行updateRuntimeUp
    * 如果runtime没有up，则返回。
    * 如果runtime已经up，则执行initializeRuntimeDependentModules
        * 开启cadvisor
        * 开启containerManager
        * 开启evictionManager
        * 开启containerLogManager
        * pluginWatcher添加Handler，并开启pluginWatcher
            * CSIPlugin
            * DevicePlugin
* 运行syncNetworkUtil：确保network utility安装到host上
    * KUBE-MARK-DROP
    * KUBE-MARK-MASQ
* 运行podKiller：通过一个chan获取不需要的pod，并删除之。
* 开启statusManager：同步pod status到apiServer中。
* 开启probeManager
* 开启runtimeClassManager：缓存RuntimeClass API Objects，供Kubelet访问。
* 开启pleg：Pod Lifecycle Event Generator。
* 开启syncLoop：程序的主要循环，监视三个channel（file、apiServer和http）的变化，并同步running state和desired state。

## Kubelet Image Manager
Kubelet Image Manager包括2个组件：
* Image Manager
* Image Garbage Collection Manager
### Image Manager
Image Manager只提供一个接口：EnsureImageExists。
```go
type ImageManager interface {
	// EnsureImageExists ensures that image specified in `container` exists.
	EnsureImageExists(pod *v1.Pod, container *v1.Container, pullSecrets []v1.Secret) (string, string, error)
}
```
简单地说就是拉取镜像。

* kubecontainer.ImageService具体执行拉取镜像的工作。
* ImagePuller封装kubecontainer.ImageService对外提供接口。ImagePuller提供了2中执行image pull的方式：并行和串行。
* Image Manager建立在ImagePuller之上提供服务，并封装kubecontainer.ImageService增加限流功能。

### Image GC Manager
Image GC Manager的start方法会运行2个循环函数：
* 每个5分钟检测一次Images，返回imagesInUse。
* 每30秒钟查看一次所有的Images，并放到image cache里。

Image GC Manager还提供了几个操作：
* GarbageCollect：根据ImageGCPolicy清理空间。
* DeleteUnusedImages：尽最大可能删除无用的Images。

## Kubelet Pod Manager
Kubelet从3个source来监听pods： file、http和apiServer。
非apiServer的pods被称为`static pods`，API server意识不到static pods的存在。
为了监控static pods的状态，kubelet为每个static pod都调用apiServer创建了对应的mirror pod。

* Static pods和mirror pods具有相同的pod full name（namespace和name）。
* Kubelet Pod Manager`不会`自动从apiServer同步pods。Kubelet中有同步的goroutine，并通过pod manager的AddPod/UpdatePod/DeletePod接口来管理kubelet pod manager的状态。
* Kubelet Pod Manager被动来缓存k8s node节点上的pods，并且保存static pods和mirror pods之间的映射。

## syncNodeStatus主要流程
* syncNodeStatus
    * registerWithAPIServer
        * initialNode
            * setNodeStatus
        * tryRegisterWithAPIServer：在apiServer中注册或者更新node的信息。
    * updateNodeStatus
        * tryUpdateNodeStatus
            * setNodeStatus
            * setLastObservedNodeAddresses
            * kl.volumeManager.MarkVolumesAsReportedInUse

## Node Lease Controller
Node Lease Controller创建和管理该kubelet的lease。
它的Run方法会运行一个循环：每隔一段时间更新一下lease。

## Kubelet Prober Manager
Kubelet Prober Manager管理pod的探测（probing）。
针对每个指定了prober的container，它创建一个probe worker。
该probe worker周期性的probe容器的状态并缓存结果。

