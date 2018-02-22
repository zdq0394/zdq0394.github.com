# Kubernetes Components
## Master Components
Master Components提供了集群的控制面板。
Master Components针对集群整体做决定（比如scheduling），检测并处理cluster events（比如，当一个replication controller的`replicas`字段没有满足时，创建新的pod）。

Master Components可以运行在集群中的任意节点上。
为了简化，安装脚本一般将所有的master components运行在同一个节点上，并且在该节点上不再运行用户的容器。

* [kube-apiserver](kube-apiserver.md)
* [kube-scheduler](kube-scheduler.md)
* [kube-controller-manager](kube-controller-manager.md)
* [cloud-controller-manager](cloud-controller-manager.md)

## Node Components
Node Components运行在每一个节点上。
Node Components维持pod的运行，并提供kubernetes runtime environment。

* [kubelet](kubelet.md)
* [kube-proxy](kube-proxy.md)
* [Container Runtime](container-runtime.md)

## Addons
Addons是实现集群特性的pods和/或services。
这些pods可以被Deployments、ReplicationControllers等管理。
Namespaced addon对象创建在`kube-system`空间下。

* [kube-dns](kube-dns.md)
* [web UI](web-ui.md)
* [container resource monitoring](container-resource-monitoring.md)
* [cluster-level logging](cluster-level-logging.md)