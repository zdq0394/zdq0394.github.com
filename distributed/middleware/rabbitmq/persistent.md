# 消息持久化
为了保证RabbitMQ在退出或者crash等异常情况下数据不丢失，需要将queue，exchange和Message都做持久化。

## Exchange的持久化
一般只需要：
```sh
channel.exchangeDeclare(exchangeName, “direct/topic/header/fanout”, true)
```
即在声明的时候讲durable字段设置为true即可。

## 队列Queue的持久化
队列queue的持久化是通过`durable=true`来实现的。
```sh
Connection connection = connectionFactory.newConnection();
Channel channel = connection.createChannel();
channel.queueDeclare("queue.persistent.name", true, false, false, null);
```
关键的是第二个参数设置为true,即durable=true。

如过将queue的持久化标识durable设置为true，则代表该队列是持久化的。如此，服务会把持久化的queue存放在硬盘上，当服务重启的时候，会重建之前被持久化的queue。

队列是可以被持久化，但是队列里面的消息是否为是持久化的还要看消息的持久化设置。

## 消息的持久化
如果要在重启后保持消息不丢失，必须设置消息是持久化的。
```sh
channel.basicPublish("exchange.persistent", "persistent", MessageProperties.PERSISTENT_TEXT_PLAIN, "persistent_test_message".getBytes());
```

这里的deliveryMode=1代表不持久化，deliveryMode=2代表持久化。
MessageProperties.PERSISTENT_TEXT_PLAIN指出将消息持久化。

## 参看文献
* https://blog.csdn.net/u013256816/article/details/60875666 
