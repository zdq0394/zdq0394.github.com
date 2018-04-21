# Redis有序集合(sorted set)
Redis有序集合和集合一样，也是string类型元素的集合，且不允许重复的成员。

不同的是**每个元素都会关联一个double类型的分数**。
redis正是通过分数来为集合中的成员进行从小到大的排序。

有序集合的成员是唯一的，但分数(score)却可以重复。

集合是通过哈希表实现的，所以添加，删除，查找的复杂度都是O(1)。 

集合中最大的成员数为**2的32次幂-1**(4294967295, 每个集合可存储40多亿个成员)。

## 语法
```
127.0.0.1:6379> zadd testzset 1.0 a 1.1 b 0.9 c 0.8 d
(integer) 4
127.0.0.1:6379> zcard testzset
(integer) 4
127.0.0.1:6379> zcount testzset 0.9 1.1
(integer) 3
127.0.0.1:6379> zincrby testzset 0.2 d
"1"
127.0.0.1:6379> zrange testzset 0 100
1) "c"
2) "a"
3) "d"
4) "b"

```
## Redis有序集合命令
* ZADD key score1 member1 [score2 member2]：向有序集合添加一个或多个成员，或者更新已存在成员的分数。
* ZCARD key：获取有序集合的成员数。
* ZCOUNT key min max：计算在有序集合中指定分数区间的成员数。
* ZINCRBY key increment member：有序集合中对指定成员的分数加上增量increment。

* ZINTERSTORE destination numkeys key1 [key2 ...]：计算给定的一个或多个有序集的交集并将结果集存储在新的有序集合key中。
* ZUNIONSTORE destination numkeys key [key ...]：计算给定的一个或多个有序集的并集，并存储在新的key中。

* ZLEXCOUNT key min max：在有序集合中计算指定字典区间内成员数量。

* ZRANGE key start stop [WITHSCORES]：通过索引区间返回有序集合成指定区间内的成员。
* ZRANGEBYLEX key min max [LIMIT offset count]：通过字典区间返回有序集合的成员。
* ZRANGEBYSCORE key min max [WITHSCORES] [LIMIT]：通过分数返回有序集合指定区间内的成员。

* ZREM key member [member ...]：移除有序集合中的一个或多个成员。
* ZREMRANGEBYLEX key min max：移除有序集合中给定的字典区间的所有成员。
* ZREMRANGEBYRANK key start stop：移除有序集合中给定的排名区间的所有成员。
* ZREMRANGEBYSCORE key min max：移除有序集合中给定的分数区间的所有成员。

* ZREVRANGE key start stop [WITHSCORES]：返回有序集中指定区间内的成员，通过索引，分数从高到底。
* ZREVRANGEBYSCORE key max min [WITHSCORES]：返回有序集中指定分数区间内的成员，分数从高到低排序。
* ZREVRANK key member：返回有序集合中指定成员的排名，有序集成员按分数值递减(从大到小)排序。

* ZSCORE key member：返回有序集中成员的分数值。

* ZSCAN key cursor [MATCH pattern] [COUNT count]：迭代有序集合中的元素（包括元素成员和元素分值）。
