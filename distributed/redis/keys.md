# Redis键（Key）
Redis键命令用于管理redis的键。

## 语法
Redis键命令的基本语法如下：

```
redis 127.0.0.1:6379> COMMAND KEY_NAME
```

以下实例中DEL是一个命令，runoobkey是一个键。 如果键被删除成功，命令执行后输出 (integer) 1，否则将输出 (integer) 0。

```
redis 127.0.0.1:6379> SET runoobkey redis
OK
redis 127.0.0.1:6379> DEL runoobkey
(integer) 1

```

## Redis keys命令

* DEL key：在key存在时删除 key。
* DUMP key：序列化给定key，并返回被序列化的值。
* EXISTS key：检查给定key是否存在。
* EXPIRE key seconds：为给定key设置过期时间。
* EXPIREAT key timestamp：EXPIREAT命令接受的时间参数是UNIX时间戳(unix timestamp)。
* PEXPIRE key milliseconds：设置key的过期时间以毫秒计。
* PEXPIREAT key milliseconds-timestamp：设置key过期时间的时间戳(unix timestamp)以毫秒计。
* KEYS pattern：查找所有符合给定模式(pattern)的key。
* MOVE key db：将当前数据库的key移动到给定的数据库db当中。
* PERSIST key：移除key的过期时间，key将持久保持。
* PTTL key：以毫秒为单位返回key的剩余的过期时间。
* TTL key：以秒为单位，返回给定key的剩余生存时间(TTL, time to live)。
* RANDOMKEY：从当前数据库中随机返回一个key。
* RENAME key newkey：修改key的名称。
* RENAMENX key newkey：仅当newkey不存在时，将key改名为newkey。
* TYPE key：返回key所储存的值的类型。