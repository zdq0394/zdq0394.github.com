# Kubernetes
## Kubernetes组件
### Master Components
* [kube-apiserver](components/kube-apiserver.md)
* [kube-scheduler](components/kube-scheduler.md)
* [kube-controller-manager](components/kube-controller-manager.md)
* [cloud-controller-manager](components/cloud-controller-manager.md)

### Node Components
* [kubelet](components/kubelet.md)
* [kube-proxy](components/kube-proxy.md)
* [Container Runtime](components/container-runtime.md)

### Addons
* [kube-dns](kube-dns.md)
* [web UI](web-ui.md)
* [container resource monitoring](container-resource-monitoring.md)
* [cluster-level logging](cluster-level-logging.md)

## Kubernetes概念
### 控制器
* [Deployments](concepts/Deployments.md)
* [ReplicaSet](concepts/ReplicaSet.md)
* [StatefulSet](concepts/StatefulSet.md)
* [DaemonSet](concepts/DaemonSet.md)
* [Job](concepts/Job.md)
* [CronJob](concepts/Cronjob.md)
* [Garbage Collector](concepts/Garbage-Collector.md)
* [Services](concepts/Services.md)
* [DNS](concepts/DNS-Pods-and-Services.md)

### Kubernetes API
* [User Guide to Service accounts](serviceaccounts/user-guide-to-sa.md)
* [Admin Guide to Service accounts](serviceaccounts/admin-guide-to-sa.md)
* [API概述](api/api_overview.md)
* [API概念](api/api_concepts.md)
* [API访问控制](acl/controlling-access-to-the-kubernetes-api.md)
* [认证](acl/authentication.md)
* [授权](acl/authorization-overview.md)

## 存储
### NFS
* [NFS](storage/nfs/nfs.md)

### CEPH
* [CEPH RBD](storage/ceph/rbd/rbd.md)
* [CEPHFS](storage/ceph/cephfs/cephfs.md)

## 网络
* [Kubernetes网络约束](network/constraints.md)
* [flannel](network/flannel.md)

## 日志监控告警
### 日志搜集

### 监控告警

## 集群部署
### Kubernetes部署
* [Centos 7.2集群部署](setup/centos72.md)

### Storage集成
* [NFS集成](storage/nfs/nfs.md)
* [Ceph RBD集成](storage/ceph_rbd/rbd.md)
* [CephFS集成](storage/cephfs/cephfs.md)

### Ingress Controller部署
* [Nginx](setup/ingress_nginx_controller.md)

## 其它
* [Pod设置时区](others/Pod-timezone.md)
* [GPU使用](others/gpu.md)