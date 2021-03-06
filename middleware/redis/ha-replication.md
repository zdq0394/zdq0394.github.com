# 主从复制
## 概述
通过持久化功能，Redis保证了即使在服务器宕机情况下数据的丢失非常少。
但是如果这台服务器出现了硬盘故障、系统崩溃等等，不仅仅是数据丢失，很可能对业务造成灾难性打击。
为了避免单点故障通常的做法是**将数据复制多个副本保存在不同的服务器上**，这样即使有其中一台服务器出现故障，其他服务器依然可以继续提供服务。
当然Redis提供了多种高可用方案包括：
* 主从复制
* 哨兵模式的主从复制
* 集群。

主从复制是指将一台Redis服务器的数据，复制到其它的Redis服务器。

前者称为主节点(master)，后者称为从节点(slave)。数据的复制是单向的，只能由主节点到从节点。

默认情况下，每台Redis服务器都是主节点，且一个主节点可以有多个从节点（或没有从节点），但一个从节点只能有一个主节点。

Redis的主从架构有两种模式：
* 一主多从
* 链式主从

**主从复制是Redis高可用的基础**。

## 主从复制三个阶段
* 连接建立阶段
* 数据同步阶段
* 命令传播阶段

## 全量复制
全量复制过程：
1. 从节点判断无法进行部分复制，向主节点发送全量复制的请求；或从节点发送部分复制的请求，但主节点判断无法进行全量复制。
2. 主节点收到全量复制的命令后，执行bgsave，在后台生成RDB文件，并使用**复制客户端缓冲区**记录从现在开始执行的所有写命令。
3. 主节点的bgsave执行完成后，将RDB文件发送给从节点；从节点首先清除自己的旧数据，然后载入接收的RDB文件，将数据库状态更新至主节点执行bgsave时的数据库状态。
4. 主节点将前述**复制客户端缓冲区**中的所有写命令发送给从节点，从节点执行这些写命令，将数据库状态更新至主节点的最新状态。
5. 如果从节点开启了AOF，则会触发bgrewriteaof的执行，从而保证AOF文件更新至主节点的最新状态。

## 部分复制
Redis2.8开始提供部分复制：psync。
部分复制功能依赖于以下三个组件：
* 主从节点各自**复制偏移量**
* 主节点**复制积压缓冲区**
* 主节点runid
## 一致性原理
Redis通过2个参数来保证从服务器和主服务器的一致性：
* min-slaves-to-write
* min-slaves-max-lag

## 参考
https://www.cnblogs.com/kismetv/p/9236731.html