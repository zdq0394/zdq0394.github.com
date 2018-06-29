# Understanding Kubernetes Objects
**Kubernetes Objects**是Kubernetes system中的持久化的实体。
Kubernetes使用这些实体表示集群的状态，它们可以描述：
* 什么应用运行在哪些节点上
* 这些应用可以使用的资源
* 这些应用如何运行的策略：比如重启策略，升级策略和容错策略

Kubernetes Object是一种**意图记录（record of intent）**——一旦创建一个object，Kubernetes system会持续工作以确保object存在。
通过创建object，Kubernetes system被要求达到一种新的状态——期望状态（desired state）。

创建、更新或者删除kubernetes objects，都需要通过Kubernetes API。可以使用`kubectl`命令行调用Kubernetes API发起请求，也可以通过`client library`直接编程操作Kubernetes API。

## Object Spec and Status
每个Kubernetes object都包括2个嵌入的`字段`，用来管理对象的配置信息：`spec`和`status`。
* spec： 必须提供，用来描述object被期望的状态。
* status： 描述object的实际状态，由kubernetes system自动补充和更新。

任何时间，Kubernetes控制机制（Control Plane）主动管理object的实际的state，以和期望的state匹配。

## Describing a Kubernetes Object
要在Kubernetes中创建一个对象，必须提供描述object期望状态的object spec和一些基本信息（比如nanme）。
当使用Kubernetes API创建object的时候，API必须在request body中包含这些信息，以JSON的格式。
通常，使用kubectl命令，并提供一个.yaml文件。kubectl命令杭工具会将.yaml文件转换为JSON格式调用Kubernetes API。

比如：
```yaml
apiVersion: apps/v1 # for versions before 1.9.0 use apps/v1beta2
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.7.9
        ports:
        - containerPort: 80
```

## Required Fields
在.yaml文件中，必须设置如下字段：
* apiVersion
* kind
* metadata
* spec

