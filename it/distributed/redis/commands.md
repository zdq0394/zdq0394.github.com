# Redis命令
Redis客户端的基本语法为：

```
$ redis-cli
```
## 在本地服务上执行命令
启动redis客户端，打开终端并输入命令redis-cli。该命令会连接**本地的redis服务**。

```
$redis-cli
redis 127.0.0.1:6379>
redis 127.0.0.1:6379> PING

PONG
```

## 在远程服务上执行命令

```
$ redis-cli -h host -p port -a password
```

```
$redis-cli -h 127.0.0.1 -p 6379 -a "mypass"
redis 127.0.0.1:6379>
redis 127.0.0.1:6379> PING

PONG
```
