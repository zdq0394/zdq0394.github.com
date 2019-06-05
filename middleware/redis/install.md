# Redis部署
## Linux下二进制安装
### 下载
下载地址：http://redis.io/download
```sh
$ wget http://download.redis.io/releases/redis-4.0.1.tar.gz
$ tar xzf redis-4.0.1.tar.gz
$ cd redis-4.0.1
$ make
```

### 启动方式
Redis启动有3种方式：

1、默认配置启动
```sh
$ src/redis-server
```
这种启动方式下，redis使用内置的默认配置启动，不是也没有默认的配置文件。

2、通过**命令行参数**自定义配置

启动的时候通过命令行参数的形式自定义配置。
```sh
$ src/redis-server --port 6380
```

3、通过**配置文件**自定义配置

启动的时候，可以增加配置文件，从指定配置文件读取配置。
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

## Docker容器化部署
* 单机部署
```sh
REDIS_IMAGE=registry.docker-cn.com/library/redis:5.0.1
docker run -d --name=redis0 --hostname=redis0 $REDIS_IMAGE
```
* [master-slave模式部署](docker/conf_master_slave.sh)
* [master-slave+哨兵模式部署](docker/master_slave_sentinel.sh)
* [cluster部署示例](cluster/cluster.sh)