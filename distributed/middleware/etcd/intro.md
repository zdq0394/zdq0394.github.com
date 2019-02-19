# etcd简介
## 简介
**etcd**是一个开源的分布式的key-value存储，把数据以可靠的方式存储在一个集群中。

**etcd**设计的初衷是可靠的存储**不常更新**的数据，并提供可靠的**watch queries**。

**etcd**存储key-value对的历史版本，并可以watch history events。

## 数据模型
**etcd**把数据存储一个**multiversion**、**persistent**的key-value存储中。
