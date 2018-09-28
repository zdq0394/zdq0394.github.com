# Kubelet Image Manager
Kubelet Image Manager包括2个组件：
* Image Manager
* Image Garbage Collection Manager
## Image Manager
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

## Image GC Manager
Image GC Manager的start方法会运行2个循环函数：
* 每个5分钟检测一次Images，返回imagesInUse。
* 每30秒钟查看一次所有的Images，并放到image cache里。

Image GC Manager还提供了几个操作：
* GarbageCollect：根据ImageGCPolicy清理空间。
* DeleteUnusedImages：尽最大可能删除无用的Images。