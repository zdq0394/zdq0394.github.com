# Kafka使用的zookeeper路径
* /brokers: Kafka集群的所有信息，包括每台broker的注册信息，集群上所有topic的信息。
* /controller: Kafka controller组件（controller负责集群的领导者选举）的注册信息，同时也负责controller的动态选举。
* /admin: 保存管理脚本的输出结果，比如删除topic，对分区进行重分配等操作。
* /isr_change_notification: 保存ISR列表发生变化的分区列表。controller会注册一个监听器实时监控该节点下子节点的变更。
* /config: 保存了Kafka集群下各种资源的定制化配置信息。比如每个topic可能有自己专属的一组配置，那么就保存在/config/topics/<topic>下。
* /cluster: 保存Kafka集群的简要信息，包括集群ID信息和集群版本号。
* /controller_epoch: 保存controller组件的版本号。Kafka使用该版本号来隔离无效的controller请求。