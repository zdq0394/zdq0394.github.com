# Kubernetes
## 基础和概念
### 概念
### 组件
## 部署
* [自定义ansible脚本]
## 镜像
* [Registry]
## 计算
* [Docker]
* [文件系统]
* [CRI]
* [Namespace/Cgroup]
## 存储
* [volume]
* [CSI]
* [Ceph]
* [local volume storage](storage/localvolume/localvolume.md)
## 网络
### service
* [clusterip]
* [nodeport]
### cni
* [kubernetes网络约束](network/constraints.md)
* [cni概述](network/cni/cni.md)
* [cni网络调用流程分析](source/network/process.md)
* [cni实现](source/network/cni.md)
### Calico
* [Calico概述](network/cni/calico/calico.md)
### Ingress
* [NginxController](setup/ingress_nginx_controller.md)
## 安全
* Authenticate
* Authorize
* Quota
## 监控告警
## 日志分析
## 中间件部署
* [ETCD](https://github.com/zdq0394/scripts/tree/master/middleware/etcd/kubernetes)
* [Redis](https://github.com/zdq0394/scripts/tree/master/middleware/redis/cluster/kubernetes)
* [Consul](https://github.com/zdq0394/scripts/tree/master/middleware/consul/kubernetes)
* [RabbitMQ](https://github.com/zdq0394/scripts/tree/master/middleware/rabbitmq/kubernetes)
* [ZooKeeper](https://github.com/zdq0394/scripts/tree/master/middleware/zookeeper/kubernetes)
* [Kafka](https://github.com/zdq0394/scripts/tree/master/middleware/kafka/kubernetes)
## 微服务
* [istio]
## [Kubernetes源码分析]
### Kubelet
* [kubelet源码概览](source/kubelet/guideline.md)
* [docker cri启动过程](source/kubelet/docker_cri.md)
* [kublet run流程](source/kubelet/kubelet.run.md)
* [volume manager](source/kubelet/volume_manager.md)
### 网络
* [网络调用流程](source/network/process.md)
* [cni框架](source/network/cni.md)
* [cni api调用cni二进制](source/network/cniapi_cnibin.md)
* [cni核心数据结构](source/network/ds.md)
### CNI
* [flannel](source/cniplugins/flannel.md)


