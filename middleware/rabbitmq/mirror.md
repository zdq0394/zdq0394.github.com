# 镜像队列
## 集群队列的问题
### 单broker节点
如果RabbitMQ集群只有一个broker节点，那么该节点的失效将导致整个服务临时性的不可用，并且可能会导致message的丢失（尤其是在非持久化message存储于非持久化queue中的时候）。

可以将所有message都设置为持久化，并且使用持久化的queue，但是这样仍然无法避免由于缓存导致的问题：因为message在发送之后和被写入磁盘并执行fsync之前存在一个虽然短暂但是会产生问题的时间窗。

通过publisher的confirm机制能够确保客户端知道哪些message已经存入磁盘，尽管如此，一般不希望遇到因单点故障导致服务不可用。
### 多broker节点
如果RabbitMQ集群是由多个broker节点构成的，那么从服务的整体可用性上来讲，该集群对于单点失效是有弹性的。

但是同时也需要注意：尽管exchange和binding能够在单点失效问题上幸免于难，但是queue和其上持有的message却不行。
这是因为`queue及其内容仅仅存储于单个节点之上`，所以一个节点的失效表现为其对应的queue不可用。
## 镜像队列
引入RabbitMQ的镜像队列机制，将queue镜像到集群中其他的节点之上。

在该实现下，如果集群中的一个节点失效了，queue能自动地切换到镜像中的另一个节点以保证服务的可用性。

在通常的用法中，针对每一个镜像队列都包含一个master和多个slave，分别对应于不同的节点。slave节点会准确地按照master执行命令的顺序执行命令，所以slave与master上维护的状态应该是完全相同的。

* 除了publish外，所有动作命令都只会向master发送，然后由master将命令执行的结果广播给slave，故看似从镜像队列中的消费操作实际上是在master上执行的。
* publish到镜像队列的所有消息总是被直接publish到master和所有的slave之上。这样一旦master失效了，message仍然可以继续发送到其他slave上。

## 失效处理
RabbitMQ集群节点失效，MQ处理策略：
* 如果某个slave失效了，系统处理做些记录外几乎啥都不做：master依旧是master，客户端不需要采取任何行动，或者被通知slave失效。 
* 如果master失效了，那么slave中的一个必须被选中为master。被选中作为新的master的slave通常是最老的那个，因为最老的slave与前任master之间的同步状态应该是最好的。然而，特殊情况下，如果没有任何一个slave与master完全同步，那么前任master中未被同步的消息将会丢失。

镜像队列消息的同步：

将新节点加入已存在的镜像队列时，默认情况下`ha-sync-mode=manual`，镜像队列中的消息不会主动同步到新节点，除非显式调用同步命令。当调用同步命令后，队列开始阻塞，无法对其进行操作，直到同步完毕。

当`ha-sync-mode=automatic`时，新加入节点时，会默认同步已知的镜像队列。由于同步过程的限制，所以不建议在生产的active队列（有生产消费消息）中操作。

```sh
rabbitmqctl list_queues name slave_pids synchronized_slave_pids   #查看那些slaves已经完成同步
rabbitmqctl sync_queue name    #手动的方式同步一个queue
rabbitmqctl cancel_sync_queue name #取消某个queue的同步功能
```

镜像队列中某个节点宕掉的后果：

当slave宕掉了，除了与slave相连的客户端连接全部断开之外，没有其他影响。

当master宕掉时，会有以下连锁反应：
1. 与master相连的客户端连接全部断开；
2. 选举最老的slave节点为master。若此时所有slave处于未同步状态，则未同步部分消息丢失；
3. 新的master节点requeue所有unack消息，因为这个新节点无法区分这些unack消息是否已经到达客户端，亦或是ack消息丢失在老的master的链路上，亦或者是丢在master组播ack消息到所有slave的链路上。所以出于消息可靠性的考虑，requeue所有unack的消息。此时客户端可能有重复消费消息。
4. 如果客户端连着slave，并且Basic.Consume消费时指定了x-cancel-on-ha-failover参数，那么客户端会受到一个Consumer Cancellation Notification通知。`如果未指定x-cancal-on-ha-failover参数，那么消费者就无法感知master宕机，会一直等待下去`。 这就告诉我们，集群中存在镜像队列时，重启master节点有风险。