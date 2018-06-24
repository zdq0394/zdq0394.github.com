# Kubernetes
## Kubernetes组件
### Master Components
* [kube-apiserver](components/kube-apiserver.md)
* [kube-scheduler](components/kube-scheduler.md)
* [kube-controller-manager](components/kube-controller-manager.md)
* [cloud-controller-manager](components/cloud-controller-manager.md)

### Node Components
* [kubelet](kubelet.md)
* [kube-proxy](kube-proxy.md)
* [Container Runtime](container-runtime.md)

### Addons
* [kube-dns](kube-dns.md)
* [web UI](web-ui.md)
* [container resource monitoring](container-resource-monitoring.md)
* [cluster-level logging](cluster-level-logging.md)

## Kubernetes概念
### 控制器
* [Deployments](usage/Deployments.md)
* [ReplicaSet](usage/ReplicaSet.md)
* [StatefulSet](usage/StatefulSet.md)
* [DaemonSet](usage/DaemonSet.md)
* [Job](usage/Job.md)
* [CronJob](usage/Cronjob.md)
* [Garbage Collector](usage/Garbage-Collector.md)
* [Services](usage/Services.md)
* [DNS](usage/DNS-Pods-and-Services.md)

## 存储
### NFS
* [NFS](storage/nfs/nfs.md)

### CEPH
* [CEPH RBD](storage/ceph/rbd/rbd.md)
* [CEPHFS](storage/ceph/cephfs/cephfs.md)

## 网络
* [Kubernetes网络约束](network/constraints.md)
* [flannel](network/flannel.md)

## Kubernetes API
* [User Guide to Service accounts](serviceaccounts/user-guide-to-sa.md)
* [Admin Guide to Service accounts](serviceaccounts/admin-guide-to-sa.md)
* [API概述](api/api_overview.md)
* [API概念](api/api_concepts.md)
* [API访问控制](acl/controlling-access-to-the-kubernetes-api.md)
* [认证](acl/authentication.md)
* [授权](acl/authorization-overview.md)

## 集群部署
### Kubernetes部署
* [Centos 7.2集群部署](setup/centos72.md)

### Storage集成
* [NFS集成](storage/nfs/nfs.md)
* [Ceph RBD集成](storage/ceph/rbd/rbd.md)
* [CephFS集成](storage/ceph/cephfs/cephfs.md)

### Ingress Controller部署
* [Nginx](setup/ingress_nginx_controller.md)

## 其它
* [Pod设置时区](others/Pod-timezone.md)
* [GPU使用](others/gpu.md)