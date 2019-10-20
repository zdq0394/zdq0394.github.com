# Metrics
## Metrics分类
* System metrics:
    * Core metrics: kubernetes运行必需依赖的metrics，需要用来实现HPA等功能。
    * Non core metrics：除了Core metrics之外的metrics。
* Service metrics：主要是指一些应用层面的metrics。
## System core metrics的Pipeline
### metrics API
Metrics API的[详细定义](https://github.com/kubernetes/metrics)，Metrics API以Aggregate Server方式集成到master apiserver中。

客户端可以像访问其它kubernetes object一样访问metrics。
### metrics server
Kubernetes-incubator的[metrics-server](https://github.com/kubernetes-incubator/metrics-server)是一个参考实现。
metrics-server目前仅支持Node和Pod两种实体的CPU和Memory两种资源的usage metrics。metrics-server通过kubelet api从kubelet server获取该指标。