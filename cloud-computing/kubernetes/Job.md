# Jobs - Run to completion
## 什么是Job
A job创建一个或多个pods并且确保一定数量的pods能够**成功的完成**。
如果一个pod成功的运行退出，则Job会将其记录为一次**成功的完成**。
当指定数量的pods**成功的完成**之后，Job本身才是**完成**的的。

删除job,会删除它创建的所有的pods。

一个简单的使用场景是：通过创建一个Job，从而确保一个pod将会成功的运行并完成。如果第一个pod失败了或者被删除了，Job会开启一个新的pod（由于节点硬件故障或者节点重启）。

A Job也可以用来并行运行多个pods。

## Job例子

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: pi
spec:
  template:
    metadata:
      name: pi
    spec:
      containers:
      - name: pi
        image: perl
        command: ["perl",  "-Mbignum=bpi", "-wle", "print bpi(2000)"]
      restartPolicy: Never
```

有可能Job生成的Pod已经结束，这时需要使用如下命令查看Pod:

``` sh
kubectl get pods --show-all
```

## Job的并行
### Job的三种类型
**非并行Job**

* 正常情况下只有一个Pod运行。除非该Pod运行失败，才会新起一个Pod。
* 一旦Pod成功的完成，则Job也完成。

**并行Job，拥有一个固定的completion count**

* .spec.completions 指定一个正整数
* 对应[1,.spec.completions]每一个值，都有一个成功完成的Pod，则Job完成。

**并行Job，拥有一个work queue**
此时不设置.spec.completions，设置.spec.Parallelism

* 每个Pod能够独立的判断它所有的伙伴是否已经结束，整个Job是否结束。
* 当任何一个Pod成功完成后，不再有新的Pod被创建
* 当任何一个Pod成功完成后，任何其它Pod都不应该在做任何工作或者有任何输出。它们都应该进入退出过程。
* 当任何一个Pod成功完成，并且其它所有的Pod都退出后，则整个Job认为成功的完成。

**控制并行性**
并行性由**.spec.parallel**控制。
默认值是1；如果设置为0，则表示Job暂停（Paused）。当增加**.spec.parallel**后，则Job恢复。

还可以通过scale命令扩展Jobs。

```sh
$ kubectl scale  --replicas=$N jobs/myjob
job "myjob" scaled
```
该命令相当于将.spec.parallel设置为10。

实际并行的pods可能会比指定值parallelism多一些或者少一些。 原因如下：

* 对于Fixed Completion Count jobs，实际运行的Pods不会超过remaining completions。过高的.spec.parallelism实际上是被忽略的。 
* 对于work queue jobs，当任何一个Pod成功完成之后，不会产生新的Pods，现有剩余的Pods可以结束。
* 控制器没有时间作出反应。
* 由于某些原因，控制器创建Pod失败，导致Pods数量少于请求的并行数目。
* The controller may throttle new pod creation due to excessive previous pod failures in the same Job.
* 当一个pod gracefully shutdown，它需要时间停止。

## Pod和Containers的处理





