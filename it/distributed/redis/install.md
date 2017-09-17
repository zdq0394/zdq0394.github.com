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
```sh
$ src/redis-server
```

### 测试
```sh
$ src/redis-cli
redis> set foo bar
OK
redis> get foo
"bar"
```

