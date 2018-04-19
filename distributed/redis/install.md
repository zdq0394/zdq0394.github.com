Redis安装
## Linux下安装
### 下载
下载地址：http://redis.io/download
```sh
$ wget http://download.redis.io/releases/redis-4.0.1.tar.gz
$ tar xzf redis-4.0.1.tar.gz
$ cd redis-4.0.1
$ make
```

### 启动
1、默认方式启动。
```sh
$ src/redis-server
```

2、自定义配置启动

启动的时候，可以增加配置文件，从指定配置文件读取配置，而不是默认配置。
```sh
$ src/redis-server redis.conf
```

### 测试
```sh
$ src/redis-cli 
127.0.0.1:6379> set foo bar
OK
127.0.0.1:6379> get foo
"bar"
127.0.0.1:6379> del foo
(integer) 1
127.0.0.1:6379> get foo
(nil)
127.0.0.1:6379> 
```
