# Kubelet Pod Manager
## 概述
Kubelet从3个source来监听pods： file、http和apiServer。
非apiServer的pods被称为`static pods`，API server意识不到static pods的存在。
为了监控static pods的状态，kubelet为每个static pod都调用apiServer创建了对应的mirror pod。

* Static pods和mirror pods具有相同的pod full name（namespace和name）。
* Kubelet Pod Manager`不会`自动从apiServer同步pods。Kubelet中有同步的goroutine，并通过pod manager的AddPod/UpdatePod/DeletePod接口来管理kubelet pod manager的状态。
* Kubelet Pod Manager被动来缓存k8s node节点上的pods，并且保存static pods和mirror pods之间的映射。


 


