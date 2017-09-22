# etcd简介
## 简介
etcd是一个开源的分布式的key-value存储。
etcd为Container Linux clusters提供共享配置、服务发现。
etcd运行在集群中的每个节点上，可以“优雅”地处理选举leader，以应对网络分区问题和leader失效等问题。

Application containers running on your cluster can read and write data into etcd. Common examples are storing database connection details, cache settings, feature flags, and more. This guide will walk you through a basic example of reading and writing to etcd then proceed to other features like TTLs, directories and watching a prefix. This guide is way more fun when you've got at least one Container Linux machine up and running — try it on Amazon EC2 or locally with Vagrant.