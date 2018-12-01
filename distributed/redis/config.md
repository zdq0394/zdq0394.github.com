# Redis配置
Redis的所有配置都可以放入一个配置文件`redis.conf`。
对于一个运行中的实例，可以通过`config`命令查看或设置配置项。

**可以通过修改redis.conf文件或使用config set命令来修改配置。**

## 语法
`Redis config`命令格式如下
* 设置配置
``` sh
127.0.0.1:6379> config set loglevel notice
OK
```
* 获取配置
``` sh
127.0.0.1:6379> config get loglevel
1) "loglevel"
2) "notice"
```

## 参数说明
可以使用config get *获取所有的配置。
```sh
127.0.0.1:6379> config get *
  1) "dbfilename"
  2) "dump.rdb"
  3) "requirepass"
  4) ""
  5) "masterauth"
  6) ""
  7) "cluster-announce-ip"
  8) ""
  9) "unixsocket"
 10) ""
 11) "logfile"
 ......
```