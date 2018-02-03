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

如果设置.spec.template.spec.restartPolicy = "OnFailure"，当container非正常退出后，会在Pod内重新启动一个，Pod仍然运行在当前Node节点上，程序需要自己处理重启问题。

如果设置.spec.template.spec.restartPolicy = "Never"，当container非正常退出后，整个Pod将会fail。Job控制器会重启一个Pod，可能会在一个不同的节点。这是程序需要自己处理临时文件、输出等等问题。

即使设置**.spec.parallelism = 1** 并且 **.spec.completions = 1** 并且 **.spec.template.spec.restartPolicy = "Never"**, 程度也可能运行两次。

如果设置.spec.parallelism并且.spec.completions大于1，程序必须处理并发问题。

## Job的终止和清理
当一个Job成功完成之后，不会有新的Pod产生，但是Pods也不会被删除。因为已经终止，所以通过命令```kubectl get pods``` 无法查看它们，需要通过命令```kubectl get pods -a```。如此，我们可以继续查看Pod的日志。Job对象也会一直保留，我们可以查看它的状态。必须通过命令显式的删除Job。

如果Pod持续失败，Job控制器会一直持续的创建新的Pod。持续创建是一个好的范式。然而，如果你不想持续的创建，可以设置一个deadline：**spec.activeDeadlineSeconds**。Job终止的时候，状态会显示：DeadlineExceeded。不会有新的Pods被建立，**存在的Pod会被删除**。

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: pi-with-timeout
spec:
  activeDeadlineSeconds: 100
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

## Job范式
Job可以用来支持Pod可靠的并发执行。
Job的初衷不是支持紧密协作进程间的并行，像科学计算。Job支持**相对独立的**进程间的并行执行。

在一个复杂的系统中，可能会有work items的多个集合。我们只考虑一个集合：batch job。

**一个workitem一个Job VS 所有workitems一个Job**
如果workitem非常多，则后者比较好。前者需要创建大量的Job，管理相对复杂。 并且，后者，资源的使用量可以通过```kubectl scale```扩展。

**一个workitem一个Pod vs 一个Pod处理多个的workitems**
前者不需要改动太多代码即可支持；后者对work items数量非常多的更合适。

**多种方式使用一个workqueue**
这需要运行一个queue服务，并对现有程序和容器进行变更以使用work queue。

## 高级用法
**指定你自己的pod selector**

通常，创建一个Job时，不需要明确指定**spec.selector**。系统的默认会添加该字段的值，并且保证不会和其它的Job重叠。

一般不要自己指定。
