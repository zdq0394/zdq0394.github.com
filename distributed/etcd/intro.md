# etcd简介
## 简介
etcd是一个开源的分布式的key-value存储。
etcd为**Container Linux clusters**提供共享配置、服务发现。
etcd运行在集群中的每个节点上，可以“优雅”地处理选举leader，以应对网络分区问题和leader失效等问题。

运行在集群中的**Application containers**可以读写etcd中的数据。etcd通常存储数据库连接详情，缓存设置和功能特征等。