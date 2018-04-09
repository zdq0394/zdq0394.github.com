# 在CentOS 7.2上部署Kubernetes集群
## 集群节点
* 192.168.100.100 kube-master
* 192.168.100.101 kube-node1
* 192.168.100.102 kube-node2

## 部署前的准备
### 关闭防火墙
``` sh
# systemctl stop firewalld.service && systemctl disable firewalld.service
```

### 禁用SELinux
``` sh
# setenforce 0
# sed -i.bak 's/SELINUX=enforcing/SELINUX=permissive/' /etc/selinux/config
```

### 在所有节点修改/etc/hosts
增加entry:
```config
192.168.100.100 kube-master
192.168.100.101 kube-node1
192.168.100.102 kube-node2
```

## 安装Kubernetes、etcd和flannel
说明：默认安装的CentOS 7.2最小系统即包含可用于安装docker等软件的yum源。 

### 在所有节点上执行以下命令安装Kubernetes等软件
``` sh
# yum -y install kubernetes etcd flannel
```

### 使用默认的yum源安装的以上软件的版本如下

``` sh
# rpm -qa | grep -E 'kube|docker|etcd|flannel'
kubernetes-master-1.5.2-0.7.git269f928.el7.x86_64
kubernetes-client-1.5.2-0.7.git269f928.el7.x86_64
docker-client-1.13.1-53.git774336d.el7.centos.x86_64
kubernetes-1.5.2-0.7.git269f928.el7.x86_64
etcd-3.2.15-1.el7.x86_64
flannel-0.7.1-2.el7.x86_64
docker-common-1.13.1-53.git774336d.el7.centos.x86_64
docker-1.13.1-53.git774336d.el7.centos.x86_64
kubernetes-node-1.5.2-0.7.git269f928.el7.x86_64
```

Kubernetes软件包提供了一些服务：
* kube-apiserver
* kube-scheduler
* kube-controller-manager
* kubelet
* kube-proxy

这些服务由systemd管理，配置集中保存在/etc/kubernetes目录下。

## 在控制节点上配置Kubernetes服务
### 设置kubernetes系统配置
参照以下内容编辑/etc/kubernetes/config：
``` config
KUBE_ETCD_SERVERS="--etcd-servers=http://kube-master:2379"
KUBE_LOGTOSTDERR="--logtostderr=true"
KUBE_LOG_LEVEL="--v=0"
KUBE_ALLOW_PRIV="--allow-privileged=false"
KUBE_MASTER="--master=http://kube-master:8080"
```

### 配置etcd服务
参照以下内容编辑/etc/etcd/etcd.conf：
```config
ETCD_NAME=default
ETCD_DATA_DIR="/var/lib/etcd/default.etcd"
ETCD_LISTEN_CLIENT_URLS="http://0.0.0.0:2379"
ETCD_ADVERTISE_CLIENT_URLS="http://0.0.0.0:2379"
```

### 配置kube-apiserver服务
参照以下内容编辑/etc/kubernetes/apiserver：
```config
KUBE_API_ADDRESS="--insecure-bind-address=0.0.0.0"
KUBE_API_PORT="--port=8080"
KUBELET_PORT="--kubelet-port=10250"
KUBE_ETCD_SERVERS="--etcd-servers=http:// 0.0.0.0:2379"
KUBE_SERVICE_ADDRESSES="--service-cluster-ip-range=10.254.0.0/16"
KUBE_ADMISSION_CONTROL="--admission-control=NamespaceLifecycle,NamespaceExists,LimitRanger,SecurityContextDeny,ServiceAccount,ResourceQuota"
KUBE_API_ARGS=""
```

### 启动kube-apiserver服务
```sh
# systemctl start etcd
# systemctl start kube-apiserver
```

kube-apiserver在启动时根据配置项“–admission-control=…ServiceAccount…”创建证书和私钥文件：
```sh
# ls /var/run/kubernetes/
apiserver.crt  apiserver.key
```

### 配置kube-controller-manager服务
参照以下内容编辑/etc/kubernetes/controller-manager：
```config
KUBE_CONTROLLER_MANAGER_ARGS="--service_account_private_key_file=/var/run/kubernetes/apiserver.key"
```

### 配置etcd保存网络覆盖配置
```sh
# etcdctl mkdir /kube-centos/network
# etcdctl mk /kube-centos/network/config "{ \"Network\": \"172.30.0.0/16\", \"SubnetLen\": 24, \"Backend\": { \"Type\": \"vxlan\" } }"
{ "Network": "172.30.0.0/16", "SubnetLen": 24, "Backend": { "Type": "vxlan" } }
```

### 配置flannel服务
参照以下内容编辑/etc/sysconfig/flanneld：
```config
FLANNEL_ETCD="http://kube-master:2379"
FLANNEL_ETCD_KEY="/kube-centos/network
```

### (重新）启动所有的服务
```sh
for SERVICES in etcd kube-apiserver kube-controller-manager kube-scheduler flanneld; do
        systemctl restart $SERVICES
        systemctl enable $SERVICES
        systemctl status $SERVICES
done
```

## 在工作节点上配置Kubernetes服务
### 设置kubernetes系统配置
同Master

参照以下内容编辑/etc/kubernetes/config：
``` config
KUBE_ETCD_SERVERS="--etcd-servers=http://kube-master:2379"
KUBE_LOGTOSTDERR="--logtostderr=true"
KUBE_LOG_LEVEL="--v=0"
KUBE_ALLOW_PRIV="--allow-privileged=false"
KUBE_MASTER="--master=http://kube-master:8080"
```

### 配置kubelet服务
参照以下内容编辑/etc/kubernetes/kubelet：
```config
KUBELET_ADDRESS="--address=0.0.0.0"
KUBELET_PORT="--port=10250"
# hostname-override即工作节点主机名，如kube-node1。
KUBELET_HOSTNAME="--hostname-override=kube-node1"
KUBELET_API_SERVER="--api-servers=http://kube-master:8080"
KUBELET_POD_INFRA_CONTAINER="--pod-infra-container-image=docker.io/kubernetes/pause:latest"
KUBELET_ARGS=""
```

### 配置flannel服务
同Master

参照以下内容编辑/etc/sysconfig/flanneld：
```config
FLANNEL_ETCD="http://kube-master:2379"
FLANNEL_ETCD_KEY="/kube-centos/network
```

### 启动服务
```sh
for SERVICES in etcd kube-proxy kubelet flanneld docker; do
        systemctl restart $SERVICES
        systemctl enable $SERVICES
        systemctl status $SERVICES
done
```

## 配置kubectl
执行以下命令完成kubectl的配置：

```sh
# kubectl config set-cluster default-cluster --server=http://kube-master:8080
# kubectl config set-context default-context --cluster=default-cluster --user=default-admin
# kubectl config use-context default-context
```

在控制节点或工作节点查看集群信息：
```sh
# kubectl get nodes
NAME         STATUS    AGE
kube-node1   Ready     1m
```

## 问题
本文来源于：https://blog.csdn.net/u012066426/article/details/72770426

实际操作过程碰到如下问题：

### docker无法启动

解决方式：
disable docker配置中的SELinux。

编辑：/etc/sysconfig/docker文件
--selinux-enabled=false
```
OPTIONS='--selinux-enabled=false --log-driver=journald --signature-verification=false'
```

### 跨节点无法ping通容器
需要修改docker启动参数，使用flannel网络。

执行如下命令，查询本机的subnet：
```sh
cat /run/flannel/subnet.env 
FLANNEL_NETWORK=172.30.0.0/16
FLANNEL_SUBNET=172.30.100.1/24
FLANNEL_MTU=1400
FLANNEL_IPMASQ=false
```

修改docker启动项目，增加：**--bip=172.30.100.1/24 --ip-masq=false --mtu=1400**
```text
# /etc/sysconfig/docker

# Modify these options if you want to change the way the docker daemon runs
OPTIONS='--selinux-enabled=false --log-driver=journald --signature-verification=false --bip=172.30.100.1/24 --ip-masq=false --mtu=1400'
```
