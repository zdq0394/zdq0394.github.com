# Raft Leader Election
## 基础
在Raft中，节点的角色有三种：
* Leader
* Follower
* Candidate
在一个正常的状态下（Leader已经选出，所有节点都OK）集群中节点**有且只有一个**处于leader状态，其余所有的都处于**follower**状态。

* Followers是被动的，它们不发出任何请求，只对Leader/Candidate的请求做出回应。
* Leader负责接收所有的Client的请求，如果Client请求到其他节点上，其他节点需要将请求转发到Leader。
* Candidate是指一个节点参与竞选leader。

Leader是有任期（term）的。
一个term包括两个阶段：选举阶段和运行阶段。在选举阶段，一个或者多个节点（candidate）参与竞争，竞争胜利者将在该任期（term）的剩余时间内成为leader。

每个节点都保存当前term值：current-term。
## Leader
一个节点在刚启动时处于follower状态。只要一个follower持续不断的收到合法的RPC（heartbeat/logentry），就一直处于follower状态。

对于Leader来说，它会持周期性(heartbeat-timeout)的发送heartbeat给followers，以维持它的leader地位。

Follower内部有一个时钟，当在election timeout时间内没有收到leader发送过来的RPC，就会进入candidate状态，发起选举。
进入candidate状态的节点：
1. 增加自己的term值
2. 投自己一票
3. 对其他的peer发送PRC：RequestVote。
    * (1)收到多数节点的同意，则节点成为leader。
    * (2)收到已经竞选成为leader的节点的heartbeat，并且该heartbeat中的term>=currentTerm，则自动退回到follower状态。
    * (3)一段时间内没有收到多数节点同意，则发起新一轮选举。

如果一段时间内都没有收到足够的多数同意票，则各个candidate**随机选择一个超时时间**再次发起选举。

## Follower节点对RequestVote的回应
当follower节点收到RequestVote请求时，执行一下动作：
1. 如果请求中的log index比自己的旧，则reject。
2. 如果follower的voteFor非空，则说明已经投票，则reject。
3. 同意，并将自己的voteFor设置为当前candidate的ID。

