# Redis客户端连接
Redis通过监听一个**TCP端口**或者**unix socket**的方式来接收来自客户端的连接。

当一个连接建立后，Redis内部会进行以下一些操作：
1. 客户端socket会被设置为非阻塞模式，因为Redis在网络事件处理上采用的是**非阻塞多路复用**模型。
2. 为这个socket设置**TCP_NODELAY**属性，禁用Nagle算法。
3. 创建一个可读的文件事件用于监听这个客户端socket的数据发送。
## 最大连接数
在Redis2.4中，最大连接数是被直接硬编码在代码里面的，而在2.6版本中这个值变成**可配置**的。
**MaxClients的默认值是10000**，可以在redis.conf中对这个值进行修改。
``` sh
config get maxclients
1) "maxclients"
2) "10000"
```
**在服务启动时设置最大连接数为100000**
```
redis-server --maxclients 100000
```
## 客户端命令
* CLIENT LIST：返回连接到redis服务的客户端列表。
* CLIENT SETNAME：设置当前连接的名称。
* CLIENT GETNAME：获取通过CLIENT SETNAME命令设置的服务名称。
* CLIENT PAUSE：挂起客户端连接，指定挂起的时间以**毫秒**计。
* CLIENT KILL：关闭客户端连接。