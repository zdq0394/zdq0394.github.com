# Redis连接
Redis连接命令主要是用于连接redis服务。

## 示例
```sh
redis 127.0.0.1:6379> AUTH "password"
OK
redis 127.0.0.1:6379> PING
PONG
```

## Redis连接命令
* AUTH password：验证密码是否正确。
* ECHO message：打印字符串。
* PING：查看服务是否运行。
* QUIT：关闭当前连接。
* SELECT index：切换到指定的数据库。