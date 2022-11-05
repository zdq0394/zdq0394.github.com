# kubeadm增加节点

## 增加worker节点
获取join命令，默认有效期24小时。
```sh
kubeadm token create --print-join-command
```

## 增加master节点
1. 获取证书
```sh
kubeadm init phase upload-certs --upload-certs
```
假设命令得到的certificate-key内容为：CERTKEY
2. 获取join命令
```sh
kubeadm token create --print-join-command --certificate-key <CERTKEY>
```

## master节点重加入
如果一个master节点(master1)不符合预期，需要先撤出然后重新加入。
1. 按照上一节的命令获取join命令。
2. (非常重要) 撤出节点(master1)：
```sh
kubeadm reset --force
```
3. 在另外的master节点上删除
```sh
kubectl delete node master1
```
4. 在已经撤出的节点master1上执行第一步获得的jion命令。

可能出现的问题：

第2步撤出master1时，需要同时撤出etcd节点，如果etcd节点没有删除，第4步会一直卡在check-etcd，日志显示etcd的健康检查失败，在执行加入etcd时候出现的错误，导致master无法加入原先的kubernetes集群。

执行如下命令`kubectl describe configmaps kubeadm-config -n kube-system`查看可以发现master1信息还在etcd中。

## 删除遗留etcd节点信息
1. 找到一个存活的etcd pod
```sh
 kubectl get pods -n kube-system | grep etcd
```
2. 进入etcd pod
```sh
kubectl exec -it etcd-master2 sh -n kube-system
```
3. 在pod中执行如下：
```
# export ETCDCTL_API=3
# alias etcdctl='etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key'
# etcdctl member list
81823df8357bcc71, started, master3, https://10.3.175.167:2380, https://10.3.175.167:2379
9d7d493298ff2c5f, started, master1, https://10.3.175.165:2380, https://10.3.175.165:2379
fac8c4b57ce3b0af, started, master2, https://10.3.175.166:2380, https://10.3.175.166:2379
# etcdctl member remove 9d7d493298ff2c5f
Member 9d7d493298ff2c5f removed from cluster bd092b6d7796dffd
# etcdctl member list
81823df8357bcc71, started, master3, https://10.3.175.167:2380, https://10.3.175.167:2379
fac8c4b57ce3b0af, started, master2, https://10.3.175.166:2380, https://10.3.175.166:2379
#
# exit
```
然后重新执行上一节，加入master节点既可。
