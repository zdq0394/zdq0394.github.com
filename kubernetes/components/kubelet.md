# Kubelet
Kubelet运行在集群中的每个node上。
Kubelet确保pod中的容器都在运行。

Kubelet保持一个**PodSpecs**的集合，并确保PodSpecs描述的containers一直运行并且是健康的。
那些非Kubernetes创建的容器，kubelet不管理。
