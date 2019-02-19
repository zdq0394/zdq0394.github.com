# Redis哨兵
## 概述
Redis Sentinel，即Redis哨兵，核心功能是`主节点的自动故障转移`。
* 监控（Monitoring）：哨兵会不断地检查主节点和从节点是否运作正常。
* 自动故障转移（Automatic Failover）：当主节点不能正常工作时，哨兵会开始自动故障转移操作，它会将失效主节点的其中一个从节点升级为新的主节点，并让其他从节点改为复制新的主节点。
* 配置提供者（Configuration Provider）：客户端在初始化时，通过连接哨兵来获得当前Redis服务的主节点地址。
* 通知（Notification）：哨兵可以将故障转移的结果发送给客户端。

哨兵模式典型的架构图如下所示：

![](pics/redis_sentinel.webp)

系统由两部分构成：
* 哨兵节点：哨兵系统由一个或多个哨兵节点组成，哨兵节点是特殊的Redis节点，不存储数据。
* 数据节点：主节点和从节点都是数据节点。

## 参看
https://www.cnblogs.com/kismetv/p/9609938.html