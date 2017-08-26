# Deployments
A Deployment controller对Pods和ReplicaSets可以进行声明式的更新。
只需要在Deployment对象中描述一个**期望状态（desired state）**， Deployment controller以一个受控的节奏和方式改变实际的状态达到指定的期望状态。 

## Use Cases

* 创建一个Deployment以利用replicaset：ReplicaSet在后台创建Pods。
* 通过更新PodTemplateSpec of the Deployment，声明Pod新的状态。这将会创建一个新的ReplicaSet。Deployment以受控的节奏将Pods从旧的ReplicaSet移除，并同步的在新的ReplicaSet中生成新的Pods。
* 回滚到前一个版本，如果当前版本不够稳定的话。
* 扩展Deployment以适应更多的负载。
* 暂停Deployment，将多个Fixes更新到PodTemplate中，然后再恢复Deployment。
* Use the status of the Deployment as an indicator that a rollout has stuck
* 清理不再需要的旧的ReplicaSets。

## 创建Deployment
```yaml 

apiVersion: apps/v1beta1 # for versions before 1.6.0 use extensions/v1beta1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 3
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.7.9
        ports:
        - containerPort: 80

```

## 更新Deployment
当且仅当Deployment的pod template发生变化时，比如labels或者container images发生变化，才会触发rollout；其它的更新，比如scalling Deployment，不会触发rollout。

## 回滚Deployment
可以回滚到前一个版本：
``` sh

$ kubectl rollout undo deployment/nginx-deployment
deployment "nginx-deployment" rolled back

```
也可以会滚到指定版本：
``` sh

$ kubectl rollout undo deployment/nginx-deployment --to-revision=2
deployment "nginx-deployment" rolled back

```

## 扩展Deployment
可以通过如下命令扩展Deployment
``` sh

$ kubectl scale deployment nginx-deployment --replicas=10
deployment "nginx-deployment" scaled

```
如果HPA开启，可以通过设置autoscaler，并且根据CPU使用率选定最小／最大副本数。
```yaml

$ kubectl autoscale deployment nginx-deployment --min=10 --max=15 --cpu-percent=80
deployment "nginx-deployment" autoscaled

```

## Pausing and Resuming a Deployment
可以在一个Deployment触发一个或者更多的更新之前Pause，然后再Resume。在Pause之后和Resume之前可以对Deployment进行一定的修补（fixes）。
再Resume之前，所有的updates都不会生效。

```yaml

$ kubectl rollout pause deployment/nginx-deployment
deployment "nginx-deployment" paused

# do many many updates and fixes here

$ kubectl rollout resume deploy/nginx-deployment
deployment "nginx" resumed

```

***We cannot rollback a paused Deployment until you resume it***

## Deployment Status

### Procesing Deployment
Kubernetes将Deployment标记为**progressing**如果有下列之一任务在运行：

* The Deployment creates a new ReplicaSet.
* The Deployment is scaling up its newest ReplicaSet.
* The Deployment is scaling down its older ReplicaSet(s).
* New Pods become ready or available (ready for at least MinReadySeconds).

可以通过如下命令观察Deployment的process状态：

``` sh

kubectl rollout status

```

### Complete Deployment
Kubernetes将Deployment标记为**complete**如果它具有如下特征：

* All of the replicas associated with the Deployment have been updated to the latest version you’ve specified, meaning any updates you’ve requested have been completed.
* All of the replicas associated with the Deployment are available.
* No old replicas for the Deployment are running.

可以通过如下命令查看一个Deployment是否处于complete

```yaml

$ kubectl rollout status deploy/nginx-deployment
Waiting for rollout to finish: 2 of 3 updated replicas are available...
deployment "nginx" successfully rolled out
$ echo $?
0

```

### Failed Deployment
Deployment可能由于下列任何一个原因而无法正确完成： 

* Insufficient quota
* Readiness probe failures
* Image pull errors
* Insufficient permissions
* Limit ranges
* Application runtime misconfiguration


## Cleanup Policy
可以设置**.spec.revisionHistoryLimit**指定Deployment保存多少历史的ReplicaSets；其它的会在后台被清理掉。默认，所有的revision history将会被保存。

***如果设置为0，会clean up all the history of your Deployment, thus that Deployment will not be able to roll back.***








