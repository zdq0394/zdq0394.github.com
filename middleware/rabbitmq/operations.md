# 运维
## 集群管理
### 增加一个节点

### 删除一个节点
比如集群rabbit@node1、rabbit@node2、rabbit@node3。将节点rabbit@node2从集群中删除。
1. 方式一
首先在rabbit@node2节点上执行命令：
```sh
rabbitmqctl stop
```
将rabbit@node2从集群中删除，在node1或者node3上执行命令：
```sh
rabbitmqctl forget_cluster_node rabbit@node2
```

2. 方式二
在rabbit@node2节点上执行命令：
```sh
rabbitmqctl stop_app
rabbitmqctl reset
rabbitmqctl start_app
```
如此rabbit@node2就转换成为一个独立的节点。rabbit@node1和rabbit@node3称为一个双节点的集群。