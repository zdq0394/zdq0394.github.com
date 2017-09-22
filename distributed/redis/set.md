# Redis 集合(Set)
Redis的Set是string类型的无序集合。集合成员是唯一的，这就意味着集合中不能出现重复的数据。

Redis中集合是通过哈希表实现的，所以添加，删除，查找的复杂度都是O(1)。

集合中最大的成员数为**2的32次幂-1**(4294967295, 每个集合可存储40多亿个成员)。

## 语法
```
redis 127.0.0.1:6379> SADD runoobkey redis
(integer) 1
redis 127.0.0.1:6379> SADD runoobkey mongodb
(integer) 1
redis 127.0.0.1:6379> SADD runoobkey mysql
(integer) 1
redis 127.0.0.1:6379> SADD runoobkey mysql
(integer) 0
redis 127.0.0.1:6379> SMEMBERS runoobkey

1) "mysql"
2) "mongodb"
3) "redis"
```
## Redis集合命令
* SADD key member1 [member2]：向集合添加一个或多个成员。
* SCARD key：获取集合的成员数。
* SDIFF key1 [key2]：返回给定所有集合的差集。
* SDIFFSTORE destination key1 [key2]：返回给定所有集合的差集并存储在destination中。
* SINTER key1 [key2]：返回给定所有集合的交集。
* SINTERSTORE destination key1 [key2]：返回给定所有集合的交集并存储在destination中。
* SISMEMBER key member：判断member元素是否是集合key的成员。
* SMEMBERS key：返回集合中的所有成员。
* SMOVE source destination member：将member元素从source集合移动到destination集合。
* SPOP key：移除并返回集合中的一个随机元素。
* SRANDMEMBER key [count]：返回集合中一个或多个随机数。
* SREM key member1 [member2]：移除集合中一个或多个成员。
* SUNION key1 [key2]：返回所有给定集合的并集。
* SUNIONSTORE destination key1 [key2]：所有给定集合的并集存储在destination集合中。
* SSCAN key cursor [MATCH pattern] [COUNT count]：迭代集合中的元素。
