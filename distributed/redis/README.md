# Redis
Redis是一个开源的（BSD许可）的，内存中的数据结构存储系统，它可以用作`数据库`、`缓存`和`消息中间件`。

Redis支持多种类型的数据结构，如`字符串（strings）`，`散列（hashes）`，`列表（lists）`，`集合（sets）`，`有序集合（sorted sets）与范围查询`，`bitmaps`，`hyperloglogs`和`地理空间（geospatial）索引半径查询`。 

Redis内置了`复制（replication）`，`LUA脚本（Lua scripting）`，`LRU驱动事件（LRU eviction）`，`事务（transactions）`和`不同级别的磁盘持久化（persistence）`，并通过`Redis哨兵（Sentinel）`和`自动分区（Cluster）`提供高可用性（high availability）。

## Redis基础
* [Redis安装](install.md)
* [Redis配置](config.md)

## Redis命令
* [Redis命令](commands.md)
* [Redis键](keys.md)
* [Redis字符串](strings.md)
* [Redis哈希](hash.md)
* [Redis列表](list.md)
* [Redis集合](set.md)
* [Redis有序集合](zset.md)
* [Redis HyperLogLog](hyperloglog.md)
* [Redis发布订阅](pubsub.md)
* [Redis事务](transaction.md)
* [Redis脚本](scripts.md)
* [Redis连接](connection.md)
* [Redis服务器](server.md)

## Redis高级功能
* [Redis数据备份与恢复](backup.md)
* [Redis安全](security.md)
* [Redis客户端连接](client_connection.md)
* [Redis管道技术](pipeline.md)
* [Redis分区](shard.md)
* [Redis性能测试](perf.md)

## Redis进阶
* [Redis高可用：持久化](ha-persistence.md)
* [Redis高可用：复制](ha-replication.md)
* [Redis高可用：哨兵](ha-sentinel.md)
* [Redis高可用：集群](ha-cluster.md)