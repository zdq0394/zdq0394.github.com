# Redis哈希(Hash)
Redis hash是一个string类型的field和value的映射表，**hash特别适合用于存储对象**。

Redis中每个hash可以存储**2的32次幂-1**个键值对（40多亿）。
## 示例
```
127.0.0.1:6379> hmset testhash a A b B c C d D
OK

127.0.0.1:6379> hmget testhash a b c
1) "A"
2) "B"
3) "C"

127.0.0.1:6379> hgetall testhash
1) "a"
2) "A"
3) "b"
4) "B"
5) "c"
6) "C"
7) "d"
8) "D"

```

## Redis hash命令
* HDEL key field1 [field2]：删除一个或多个哈希表字段。
* HEXISTS key field：查看哈希表key中指定字段是否存在。
* HGET key field：获取存储在哈希表中指定字段的值。
* HSET key field value：将哈希表key中的字段field的值设为value。
* HSETNX key field value：只有在字段field不存在时，设置哈希表字段的值。
* HGETALL key：获取哈希表中指定key的所有字段和值。
* HINCRBY key field increment：为哈希表key的指定字段的整数值增加increment。
* HINCRBYFLOAT key field increment：为哈希表key的指定字段的浮点数值加上增量increment。
* HKEYS key：获取哈希表中的所有字段。
* HVALS key：获取哈希表中所有值。
* HLEN key：获取哈希表中字段的数量。
* HMGET key field1 [field2]：获取哈希表key中给定多个字段的值。
* HMSET key field1 value1 [field2 value2 ]：同时将多个field-value对设置到哈希表key中。
* HSCAN key cursor [MATCH pattern] [COUNT count]：迭代哈希表中的键值对。