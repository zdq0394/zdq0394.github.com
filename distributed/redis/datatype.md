# Redis数据类型
Redis支持五种数据类型：
* string（字符串）
* hash（哈希）
* list（列表）
* set（集合）
* zset(sorted set：有序集合)

## String（字符串）
* string是redis最基本的类型，可以理解成与Memcached一模一样的类型。一个key对应一个value。
* string类型是二进制安全的，即redis的string可以包含任何数据。比如jpg图片或者序列化的对象。
* string类型是redis最基本的数据类型，**一个键最大能存储512MB**。

```sh
redis 127.0.0.1:6379> set name "value"
OK
redis 127.0.0.1:6379> get name
"value"
```

## Hash（哈希）
* Redis hash是一个**键值对**集合。
* Redis hash是一个**string类型**的field和value的映射表，hash特别适合用于存储对象。
* 每个hash可以存储**2的32次幂-1**个键值对（40多亿）。
```sh
127.0.0.1:6379> hmset user:1 username jack password jackpass point 99
OK
127.0.0.1:6379> hgetall user:1
1) "username"
2) "jack"
3) "password"
4) "jackpass"
5) "point"
6) "99"
```
```sh
127.0.0.1:6379> hmget user:1 username
1) "jack"
127.0.0.1:6379> hmget user:1 password
1) "jackpass"
```

## List（列表）
* Redis列表是简单的字符串列表，按照插入顺序排序。
* 可以添加一个元素到列表的头部（左边）或者尾部（右边）。
* 列表最多可存储**2的32次幂-1**个元素。

```sh
127.0.0.1:6379> lpush lang c java go
(integer) 3
127.0.0.1:6379> lpush lang c++
(integer) 4

127.0.0.1:6379> lrange lang 0 3
1) "c++"
2) "go"
3) "java"
4) "c"
```
## Set（集合）
* Redis的Set是string类型的无序集合。
* 集合是通过哈希表实现的，所以添加，删除，查找的复杂度都是O(1)。
* 集合中最大的成员数为**2的32次幂-1**.

**sadd命令**

添加一个string元素到key对应的set集合中，成功返回1；如果元素已经在集合中返回0，key对应的set不存在返回错误。
**sadd key member**

```sh
127.0.0.1:6379> sadd books java go c++
(integer) 3
127.0.0.1:6379> sadd books nodejs java
(integer) 1
127.0.0.1:6379> sadd books go
(integer) 0
127.0.0.1:6379> smembers books
1) "nodejs"
2) "java"
3) "go"
4) "c++"
```
## zset(sorted set：有序集合)
* Redis zset和set 一样也是string类型元素的集合，且不允许重复的成员。
* 不同的是每个元素都会关联一个double类型的分数。redis正是通过分数来为集合中的成员进行从小到大的排序。
* zset的成员是唯一的，但分数(score)却可以重复。

**zadd 命令**
**zadd key score member**

```
127.0.0.1:6379> zadd mybooks 0.1 java
(integer) 1
127.0.0.1:6379> zadd mybooks 0.09 c
(integer) 1
127.0.0.1:6379> zadd mybooks 0.12 go
(integer) 1

127.0.0.1:6379> zrangebyscore mybooks 0.1 0.11
1) "java"
127.0.0.1:6379> zrangebyscore mybooks 0.1 0.12
1) "java"
2) "go"
```
