# 手动解除k8s对ceph rbd的挂载
## pod漂移失败
在kubernetes中,如果某个节点出现问题(比如kubelet服务不可用), 集群会自动把这个节点上的pod飘到其他节点。但是，如果一个pod挂载了ceph rbd类型的存储卷(pv)，那么这个pod在新节点上是无法正常启动的。会提示如下错误：
``` sh
Multi-Attach errorforvolume"pvc-4f91d1a6-fcec-11e8-bd06-6c92bf74374a"Volumeisalready exclusively attached to one nodeandcan't be attached to another。
```

## 原因如下
kubelet服务是与集群通信的。如果这个服务出现问题，集群就会与这个节点失联，而这个节点上的容器是正常在运行的，所以这个容器还会占用这个pv的挂载。而集群并不能删掉这个容器，也不能控制这个节点取消挂载。

## 方法一:手动解除挂载
1. 强制删除有问题的pod
```sh
kubectl delete pod -n <namespace> <pod name> --grace-period=0 –force
```
2. 查看新建pod的状态
```sh
kubectl describe pod -n <namespace> <pod name>
```
在event中发现 Multi-Attach 的异常
3. 查看这个pv的信息
```sh
kubectl describe pv <pv name>
```
可以Source.RBDImage获取相关的rbd name。
```sh
rbd status <rbd name>
```
可以看到这个rbd的image正在被某个node使用。
4. 到这个node上去查看rbd的使用情况,可以看到rbd挂载到node的设备名:
```sh
rbd showmapped|grep <rbd name>
```
5. 找到之前pod产生的容器，手动将它停止

6. 解除设备到容器(pod)的挂载。(第四步的获取设备)
```sh
umount /dev/rbd0
```
7. 解除node对ceph-rbd的映射
```sh
rbd unmap <rbd name>
```
8. 重启新的pod
```sh
kubectl delete po -n <namespace name> <pod name>
```

