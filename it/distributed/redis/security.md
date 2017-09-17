# Redis安全
通过redis的配置文件设置密码参数，这样客户端连接到redis服务就需要密码验证，这样可以让redis服务更安全。
通过以下命令查看是否设置了密码验证：

```
127.0.0.1:6379> CONFIG get requirepass
1) "requirepass"
2) ""

```
默认情况下requirepass参数是空的，这就意味着无需通过密码验证就可以连接到redis服务。

可以通过以下命令来修改该参数：

```
127.0.0.1:6379> CONFIG set requirepass "runoob"
OK
127.0.0.1:6379> CONFIG get requirepass
1) "requirepass"
2) "runoob"
```

设置密码后，客户端连接redis服务就需要密码验证，否则无法执行命令。

## AUTH

```
127.0.0.1:6379> AUTH password
```

示例：

```
127.0.0.1:6379> AUTH "runoob"
OK
127.0.0.1:6379> SET mykey "Test value"
OK
127.0.0.1:6379> GET mykey
"Test value"
```
