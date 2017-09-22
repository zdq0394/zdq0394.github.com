# Redis事务
Redis事务可以一次执行多个命令，并且带有以下两个重要的保证：

* 事务是一个单独的隔离操作：事务中的所有命令都会序列化、按顺序地执行。事务在执行的过程中，不会被其他客户端发送来的命令请求所打断。
* 事务是一个原子操作：事务中的命令要么全部被执行，要么全部都不执行。

一个事务从开始到执行会经历以下三个阶段：

* 开始事务。
* 命令入队。
* 执行事务。

## 示例
先以MULTI开始一个事务，然后将多个命令入队到事务中，最后由EXEC命令触发事务，一并执行事务中的所有命令：

```
redis 127.0.0.1:6379> MULTI
OK

redis 127.0.0.1:6379> SET book-name "Mastering C++ in 21 days"
QUEUED

redis 127.0.0.1:6379> GET book-name
QUEUED

redis 127.0.0.1:6379> SADD tag "C++" "Programming" "Mastering Series"
QUEUED

redis 127.0.0.1:6379> SMEMBERS tag
QUEUED

redis 127.0.0.1:6379> EXEC
1) OK
2) "Mastering C++ in 21 days"
3) (integer) 3
4) 1) "Mastering Series"
   2) "C++"
   3) "Programming"

```
## Redis事务命令
* DISCARD：取消事务，放弃执行事务块内的所有命令。
* EXEC：执行所有事务块内的命令。
* MULTI：标记一个事务块的开始。
* UNWATCH：取消WATCH命令对所有key的监视。
* WATCH key [key ...]：监视一个(或多个) key，如果在事务执行之前这个(或这些)key被其他命令所改动，那么事务将被打断。