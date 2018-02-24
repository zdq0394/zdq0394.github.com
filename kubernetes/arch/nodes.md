# Nodes
## What is a node
Node是Kubernetes中的工作节点（worker machine），曾经称作`minion`。
一个node可以是一个虚拟机也可以是一个物理机。
Node上部署有运行和管理pods的必需的服务，node上部署的服务包括：Docker、kubelet和kube-proxy。
Node受master组件的管理。

## Node Status
Node的status信息包括如下：
* Addresses
* Phase（deprecated）
* Condition
* Capacity
* Info

### Addresses
根据Cloud Provider或者裸金属配置的不同，该字段的含义不同。
* HostName： node's kernel汇报的hostname。可以通过`kubelet --hostname-override`参数覆盖。
* ExternalIP： node的IP地址，可以从集群外部访问。
* InternalIP： node的内部IP地址，只能在集群内部访问。

### Phase
已经废弃

### Condition
Node的conditions字段描述了`Running nodes`的状态。
* OutOfDisk： 没有足够的磁盘空间增加pods
* Ready： node是healthy并且ready接收pods。如果node controller超过**40s**没有接收到来自kubelet的心跳信息，则该字段为`Unknown`。
* MemoryPressure：内存剩余空间不足
* DiskPressure： 磁盘剩余空间不足
* NetworkUnavailable： 网络配置不正确
* ConfigOK： kubelet配置正确

Node的condition信息是一个JSON对象。
```yaml
"conditions": [
  {
    "type": "Ready",
    "status": "True"
  }
]
```

如果Ready的状态为`Unknown`或者`False`超过一定的时间（由p`pod-eviction-timeout`指定，默认是5分钟），Node Controller会给kube-controller-manager传递一个参数，将该node上的所有pods调度为删除（scheduled for deletion）。
在某些情况下，node网络不可达，kube-apiserver无法和kubelet通信，删除pod的指令无法下达给kubelet。在这个时间段内，那些调度为删除的pods会在割裂的node上继续运行。

Kubernetes 1.5之前，node controller会从kube-apiserver上强制删除这些unreachable pods。

KUbernetes 1.5及之后，node controller不会强制删除，除非确认这些pods已经停止运行。可以发现这些pods处于状态`Terminating`或者`Unkonwn`。管理员可以手工删除node object，这些node上的所有pods江会被删除。

### Capacity
Capacity用来描述节点的资源：
* CPU
* Memory
* Maximum number of pods

### Info
关于该node的通用信息：
* 内核版本
* Kubernetes版本（kubelet版本、kube-proxy版本）
* Docker版本
* OS name
这些信息是由kubelet从node上搜集的。

## Management
和pods和services这些对象不同，node不是由Kubernetes创建出来的：node是由cloud provider提供的，或者已经存在资源池。

Kubernetes创建一个node，只是创建一个object表示已经存在的node。
创建完成之后，Kubernetes将会验证该node是否有效。

可以通过如下文件创建一个node：
```yaml
{
  "kind": "Node",
  "apiVersion": "v1",
  "metadata": {
    "name": "10.240.79.157",
    "labels": {
      "name": "my-first-k8s-node"
    }
  }
}
```
Kubernetes将会创建一个node object，并进行health checking，验证metadata.name字段是否有效。

如果一个node是有效的，那么node上所有的服务都是running的，并且准备接收pods。
否则，该node将会被Kubernetes忽略。
`Invalid`的nodes不会被删除（除非显式删除），并持续进行health checking，是否valid。

目前和Kubernetes nodes交互的组件有3个：
* node controller
* kubelet
* kubectl

### Node Controller
Node Controller是Kubernetes的一个master组件，管理着nodes的各个方面。

在node的生命周期内，node controller扮演了多种角色：
1. 当node注册进入集群时，为node分配CIDR地址块（如果开启了CIDR assignment）。
2. 保持node controller内部的node列表和cloud provider提供的可用机器列表一致。
3. 监控node的health。


### Self-Registration of Nodes
当kubelet添加`--register-node=true`（默认）时，kubelet会尝试向APIServer注册自己。
这是首选的方式。

