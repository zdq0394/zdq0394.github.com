# Redis数据类型
Redis支持五种数据类型：string（字符串），hash（哈希），list（列表），set（集合）及zset(sorted set：有序集合)。
## String（字符串）
* string是redis最基本的类型，你可以理解成与Memcached一模一样的类型，一个key对应一个value。
* string类型是二进制安全的。意思是redis的string可以包含任何数据。比如jpg图片或者序列化的对象。
* string类型是Redis最基本的数据类型，**一个键最大能存储512MB**。

```
redis 127.0.0.1:6379> SET name "runoob"
OK
redis 127.0.0.1:6379> GET name
"runoob"
```

## Hash（哈希）
* Redis hash是一个键名对集合。
* Redis hash是一个string类型的field和value的映射表，hash特别适合用于存储对象。
* 每个hash可以存储**2的32次幂-1**键值对（40多亿）
```
127.0.0.1:6379> HMSET user:1 username runoob password runoob points 200
OK
127.0.0.1:6379> HGETALL user:1
1) "username"
2) "runoob"
3) "password"
4) "runoob"
5) "points"
6) "200"
```

## List（列表）
* Redis列表是简单的字符串列表，按照插入顺序排序。
* 可以添加一个元素到列表的头部（左边）或者尾部（右边）。
* 列表最多可存储**2的32次幂-1**个元素。

```
redis 127.0.0.1:6379> lpush runoob redis
(integer) 1
redis 127.0.0.1:6379> lpush runoob mongodb
(integer) 2
redis 127.0.0.1:6379> lpush runoob rabitmq
(integer) 3
redis 127.0.0.1:6379> lrange runoob 0 10
1) "rabitmq"
2) "mongodb"
3) "redis"
redis 127.0.0.1:6379>
```

## Set（集合）
* Redis的Set是string类型的无序集合。
* 集合是通过哈希表实现的，所以添加，删除，查找的复杂度都是O(1)。
* 集合中最大的成员数为**2的32次幂-1**.

**sadd命令**

添加一个string元素到key对应的set集合中，成功返回1,如果元素已经在集合中返回0,key对应的set不存在返回错误。
**sadd key member**

```
redis 127.0.0.1:6379> sadd runoob redis
(integer) 1
redis 127.0.0.1:6379> sadd runoob mongodb
(integer) 1
redis 127.0.0.1:6379> sadd runoob rabitmq
(integer) 1
redis 127.0.0.1:6379> sadd runoob rabitmq
(integer) 0
redis 127.0.0.1:6379> smembers runoob

1) "rabitmq"
2) "mongodb"
3) "redis"
```
## zset(sorted set：有序集合)
* Redis zset和set 一样也是string类型元素的集合,且不允许重复的成员。
* 不同的是每个元素都会关联一个double类型的分数。redis正是通过分数来为集合中的成员进行从小到大的排序。
* zset的成员是唯一的,但分数(score)却可以重复。

**zadd 命令**
**zadd key score member**

```
redis 127.0.0.1:6379> zadd runoob 0 redis
(integer) 1
redis 127.0.0.1:6379> zadd runoob 0 mongodb
(integer) 1
redis 127.0.0.1:6379> zadd runoob 0 rabitmq
(integer) 1
redis 127.0.0.1:6379> zadd runoob 0 rabitmq
(integer) 0
redis 127.0.0.1:6379> ZRANGEBYSCORE runoob 0 1000

1) "redis"
2) "mongodb"
3) "rabitmq"
```
