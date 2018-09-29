# Kubelet源码模块
## container
描述container的运行状态信息及辅助方法，并定义了管理容器需要的主要接口。
主要对象定义：
* Container：provides the runtime information for a container, such as ID, hash, state of the container.
* PodStatus：represents the status of the pod and its containers.
* ContainerStatus：represents the status of a container.
* Image：一个容器镜像的基本信息。
* RuntimeStatus：contains the status of the runtime.
此外还定义了几个关键接口
* Runtime： defines the interfaces that should be implemented by a container runtime
* StreamingRuntime：interface implemented by runtimes that handle the serving of the streaming calls (exec/attach/port-forward) themselves. In this case, Kubelet should redirect to the runtime server.
* ContainerCommandRunner：synchronously executes the command in the container, and returns the output.

## cm： container manager
主要用来管理一个节点上运行的众多容器。
* ContainerManager：管理整个node层面的容器。
* CGroupManager：对cgroup管理，支持cgroup的创建、删除和更新。
* PodContainerManager：存储和管理pod层面的容器。Pod Workders与PodContainerManager交互以创建/删除某个pod的容器。

## pod：pod manager
主要用来管理一个节点上的众多pods。
Kubelets通过和pod manager来管理pods，并维护static pods和mirror pods之间的mapping关系。

Kubelet从3个source来监听pods： file、http和apiServer。
非apiServer的pods被称为`static pods`，API server意识不到static pods的存在。
为了监控static pods的状态，kubelet为每个static pod都调用apiServer创建了对应的mirror pod。

* Static pods和mirror pods具有相同的pod full name（namespace和name）。
* Kubelet Pod Manager`不会`自动从apiServer同步pods。Kubelet中有同步的goroutine，并通过pod manager的AddPod/UpdatePod/DeletePod接口来管理kubelet pod manager的状态。
* Kubelet Pod Manager被动来缓存k8s node节点上的pods，并且保存static pods和mirror pods之间的映射。

## prober
Kubelet Prober Manager管理pod的探测（probing）。
针对每个指定了prober的container，它创建一个probe worker。
该probe worker周期性的probe容器的状态并缓存结果。

## images
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

## kuberuntime
KubeGenericRuntime接口包含3个接口：
* kubecontainer.Runtime
* kubecontainer.StreamingRuntime
* kubecontainer.ContainerCommandRunner
具体实现struct：kubeGenericRuntimeManager

在kubelet中，不是通过KubeGenericRuntime接口调用kubeGenericRuntimeManager中的方法；而是通过三个子接口调用。
```
runtime, err := kuberuntime.NewKubeGenericRuntimeManager(....)
....
klet.containerRuntime = runtime
klet.streamingRuntime = runtime
klet.runner = runtime
```

kuberuntime包中主要围绕接口`KubeGenericRuntime`，也就是3个子接口`kubecontainer.Runtime`、`kubecontainer.StreamingRuntime`和`kubecontainer.ContainerCommandRunner`来实现。
* kuberuntime_manager.go主要实现kubecontainer.Runtime中非container相关的方法。
* kuberuntime_images.go主要实现kubecontainer.Runtime包含的ImageService的方法。
* kuberuntime_sandbox.go主要实现kubecontainer.StreamingRuntime中的GetPortForward方法。
* kuberuntime_container.go主要实现kubecontainer.StreamingRuntime中的GetExec/GetAttach方法，kubecontainer.ContainerCommandRunner的RunInContainer方法以及runtime中container相关的方法。

当然，以上这些方法的实现都是借助于CRI的两个规范RuntimeService和ImageService来实现的。

## nodelease
Node Lease Controller创建和管理该kubelet的lease。
它的Run方法会运行一个循环：每隔一段时间更新一下lease。

## nodestatus
包含更新Node Status的方法。