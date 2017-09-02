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


