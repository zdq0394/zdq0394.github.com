# Raft Log Replication
Raft的**log replication**是单向的，能且只能从leader复制到follower。

当Leader收到一个客户端请求时，将在本地生成一个log entry，加入到自己log中，然后发起一个RPC：**AppendEntries，将log entry发送到followers节点。

Leader决定什么时候把一个log entry应用到state machine是安全的。如此一个log entry是**committed**。

Raft确保committed entries是持久的，并且会逐渐被state machine执行。

A log entry将被**committed**，当leader将它复制到多数节点之后；**这也意味着该log entry之前的所有entres都被commited，包括之前term产生的log entries。**

## Log Matching Property
* If two entries in different logs have the same index and term，then they store the same command。
* If two entries in different logs have the same index and term，then the logs are identical in all preceding entries。

针对每个peer，leader保存一个值nextIndex。**nextIndex**是下一个leader要同步到该peer的log entry。
在同步的时候，还会将该log entry前面的一个log entry的term（pre-term）和index(pre-index)发送过去，，由follower进行一致性验证。

在follower端，如果pre-term或者pre-index不一致，则reject。
此时，Leader要将nextIndex-1，然后再同步，直到找到合适的log entry进行同步。

