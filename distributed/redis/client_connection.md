# Redis客户端连接
Redis通过监听一个TCP端口或者Unix socket的方式来接收来自客户端的连接，当一个连接建立后，Redis内部会进行以下一些操作：

1. 首先，客户端socket会被设置为非阻塞模式，因为Redis在网络事件处理上采用的是非阻塞多路复用模型。
2. 然后为这个socket设置TCP_NODELAY属性，禁用Nagle算法。
3. 然后创建一个可读的文件事件用于监听这个客户端socket的数据发送。

## 最大连接数
在Redis2.4中，最大连接数是被直接硬编码在代码里面的，而在2.6版本中这个值变成可配置的。
maxclients的默认值是10000，可以在redis.conf中对这个值进行修改。

```
config get maxclients

1) "maxclients"
2) "10000"
```

**在服务启动时设置最大连接数为 100000**

```
redis-server --maxclients 100000
```

## 客户端命令
* CLIENT LIST：返回连接到redis服务的客户端列表。
* CLIENT SETNAME：设置当前连接的名称。
* CLIENT GETNAME：获取通过CLIENT SETNAME命令设置的服务名称。
* CLIENT PAUSE：挂起客户端连接，指定挂起的时间以毫秒计。
* CLIENT KILL：关闭客户端连接。