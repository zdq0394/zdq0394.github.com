# Redis字符串(String)
## 语法
形式：
```
redis 127.0.0.1:6379> COMMAND KEY_NAME
```
示例：
```
redis 127.0.0.1:6379> SET runoobkey redis
OK
redis 127.0.0.1:6379> GET runoobkey
"redis"
```

## Redis字符串命令
* SET key value：设置指定key的值。
* GET key：获取指定key的值。
* GETRANGE key start end：返回key的值字符串的子串，**start和end都包括在子串之内**。
* GETSET key value：将给定key的值设为value，并返回key的旧值(old value)。
* GETBIT key offset：对key所储存的字符串值，获取指定偏移量上的位(bit)。
* MGET key1 [key2..]：获取所有（一个或多个）给定key的值。
* SETBIT key offset value：对key所储存的字符串值，设置或清除指定偏移量上的位(bit)。
* SETEX key seconds value：将值value关联到key，并将key的过期时间设为seconds(以秒为单位)。
* SETNX key value：只有在key不存在时设置key的值。
* SETRANGE key offset value：用value参数覆写给定key所储存的字符串值，从偏移量offset开始。
* STRLEN key：返回key所储存的字符串值的长度。
* MSET key value [key value ...]：同时设置一个或多个key-value对。
* MSETNX key value [key value ...]：同时设置一个或多个key-value对，当且仅当所有给定key都不存在。
* PSETEX key milliseconds value：这个命令和SETEX命令相似，但它以毫秒为单位设置key的生存时间，而不是像SETEX命令那样，以秒为单位。
* INCR key：将key中储存的数字值增一。
* INCRBY key increment：将key所储存的值加上给定的增量值（increment）。
* INCRBYFLOAT key increment：将key所储存的值加上给定的浮点增量值（increment）。
* DECR key：将key中储存的数字值减一。 
* DECRBY key decrement：将key所储存的值减去给定的减量值（decrement）。
* APPEND key value：如果key已经存在并且是一个字符串，APPEND命令将value追加到key原来的值的末尾，如果key不存在，则相当于命令set。