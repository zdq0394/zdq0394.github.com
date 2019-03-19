# 事务和消息确认机制
通过RabbitMQ的持久化机制可以确保消息在broker重启之后持久化的消息不会丢失。
但是，如何确保生产者把消息发送到broker呢？
再者，消费者取到消息之后还没来得及处理就崩溃了，那这条消息如何处理呢？
本文介绍生产者和消费者的消息确认机制。
## 生产者端
在生产者端，RabbitMQ提供了两种方式：
* 通过AMQP事务机制实现，这也是AMQP协议层面提供的解决方案
* 通过将channel设置成confirm模式来实现
### 事务
RabbitMQ中与事务机制有关的方法有三个：
* txSelect()
* txCommit()
* txRollback()
txSelect用于将当前channel设置成transaction模式，txCommit用于提交事务，txRollback用于回滚事务。

缺点：采用事务机制实现会降低RabbitMQ的消息吞吐量。
### Confirm机制
生产者将信道设置成confirm模式。
一旦信道进入confirm模式，所有在该信道上发布的消息都会被指派一个唯一的ID(从1开始)。
一旦消息被投递到所有匹配的队列之后，broker就会发送一个确认给生产者（包含消息的唯一ID），这就使得生产者知道消息已经正确到达目的队列了，如果消息和队列是持久化的，那么确认消息会在消息写入磁盘之后发出。

Broker回传给生产者的确认消息中deliver-tag域包含了确认消息的序列号，此外broker也可以设置basic.ack的multiple域，表示这个序列号之前的所有消息都已经得到了处理。

Confirm模式最大的好处在于它是异步的，一旦发布一条消息，生产者应用程序就可以在等信道返回确认的同时继续发送下一条消息。
当消息最终得到确认之后，生产者应用便可以通过回调方法来处理该确认消息。
如果RabbitMQ因为自身内部错误导致消息丢失，就会发送一条`nack消息`，生产者应用程序同样可以在回调方法中处理该nack消息。

在channel被设置成confirm模式之后，所有被publish的后续消息都将被confirm（即ack）或者被nack一次。
但是没有对消息被confirm的快慢做任何保证，并且同一条消息不会既被confirm又被nack。

生产者通过调用channel的confirmSelect方法将channel设置为confirm模式。
如果没有设置no-wait标志的话，broker会返回confirm.select-ok表示同意发送者将当前channel信道设置为confirm模式。
从目前RabbitMQ最新版本3.6来看，如果调用了channel.confirmSelect方法，默认情况下是直接将no-wait设置成false的，也就是默认情况下broker是必须回传confirm.select-ok的。

* 普通confirm模式：每发送一条消息后，调用waitForConfirms()方法，等待服务器端confirm。实际上是一种串行confirm了。
* 批量confirm模式：每发送一批消息后，调用waitForConfirms()方法，等待服务器端confirm。
* 异步confirm模式：提供一个回调方法，服务端confirm了一条或者多条消息后Client端会回调这个方法。

## 消费者端
为了保证消息从队列可靠地到达消费者，RabbitMQ提供消息确认机制(message acknowledgment)。
消费者在声明队列时，可以指定noAck参数，当noAck=false时，RabbitMQ会等待消费者显式发回ack信号后才从内存(和磁盘，如果是持久化消息的话)中移去消息。
否则，RabbitMQ会在队列中消息被消费后立即删除它。

采用消息确认机制后，只要令noAck=false，消费者就有足够的时间处理消息(任务)，不用担心处理消息过程中消费者进程挂掉后消息丢失的问题，因为RabbitMQ会一直持有消息直到消费者显式调用basicAck为止。

当noAck=false时，对于RabbitMQ服务器端而言，队列中的消息分成了两部分：一部分是等待投递给消费者的消息；一部分是已经投递给消费者，但是还没有收到消费者ack信号的消息。

如果服务器端一直没有收到消费者的ack信号，并且消费此消息的消费者已经断开连接，则服务器端会安排该消息重新进入队列，等待投递给下一个消费者（也可能还是原来的那个消费者）。

RabbitMQ不会为未ack的消息设置超时时间，它判断此消息是否需要重新投递给消费者的唯一依据是`消费该消息的消费者连接是否已经断开`。
这么设计的原因是RabbitMQ允许消费者消费一条消息的时间可以很久很久。

* basicReject：是接收端告诉服务器这个消息我拒绝接收,不处理,可以设置是否放回到队列中还是丢掉，而且只能一次拒绝一个消息,官网中有明确说明不能批量拒绝消息，为解决批量拒绝消息才有了basicNack。
```sh
channel.BasicReject(result.DeliveryTag, false);
第二个参数：requeue。
```
* basicNack：可以一次拒绝N条消息，客户端可以设置basicNack方法的multiple参数为true，服务器会拒绝指定了delivery_tag的所有未确认的消息(tag是一个64位的long值，最大值是9223372036854775807)。
```sh
channel.BasicNack(result.DeliveryTag, true, true);
```
* BasicRecover：补发操作，其中的参数如果为true是把消息退回到queue但是有可能被其它的consumer接收到，设置为false是只补发给当前的consumer。
```sh
//补发消息 true退回到queue中/false只补发给当前的consumer
channel.BasicRecover(true);
```

## 参看文献
* https://blog.csdn.net/u013256816/article/details/55515234 