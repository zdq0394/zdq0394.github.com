# Redis发布订阅
Redis的**发布订阅（pub/sub）**是一种消息通信模式：发送者（pub）发送消息，订阅者（sub）接收消息。

Redis客户端可以**订阅任意数量的频道**。

下图展示了频道channel1，以及订阅这个频道的三个客户端——client2、client5和client1之间的关系：

![](pics/pubsub1.png)

当有新消息通过PUBLISH命令发送给频道channel1时，这个消息就会被发送给订阅它的三个客户端：

![](pics/pubsub2.png)

## 示例
首先创建订阅频道名为redisChat:
```
Reading messages... (press Ctrl-C to quit)
1) "subscribe"
2) "testchannel"
3) (integer) 1

```
现在，重新开启个redis客户端，然后在同一个频道redisChat发布两次消息，订阅者就能接收到消息。

```
127.0.0.1:6379> publish testchannel "hello world"
(integer) 1
127.0.0.1:6379> publish testchannel "hello china"
(integer) 1
```
订阅者的客户端会显示如下消息：
```
1) "message"
2) "testchannel"
3) "hello world"
1) "message"
2) "testchannel"
3) "hello china"
```

## Redis发布订阅命令
* SUBSCRIBE [channel [channel ...]]：订阅指定的频道。
* UNSUBSCRIBE [channel [channel ...]]：指退订给定的频道。
* PSUBSCRIBE pattern [pattern ...]：订阅一个或多个符合给定模式的频道。
* PUNSUBSCRIBE [pattern [pattern ...]]：退订所有给定模式的频道。
* PUBSUB subcommand [argument [argument ...]]：查看订阅与发布系统状态。
* PUBLISH channel message：将信息发送到指定的频道。



