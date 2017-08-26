# Deployments
A Deployment controller对Pods和ReplicaSets可以进行声明式的更新。
我们只需要在Deployment对象中指定一个**期望状态（desired state）**， Deployment controller将以一个受控的节奏和方式改变实际的状态从而达到指定的期望状态。 

## Use Cases
下面是Deployment的典型用例：

* 创建一个Deployment以生成replicaset。ReplicaSet将在后台创建Pods。
* 通过更新Deployment的**PodTemplateSpec**，声明Pods新的状态。这样，将会创建一个新的ReplicaSet。Deployment将以受控的节奏将Pods从旧的ReplicaSet移除，并同步地在新的ReplicaSet中生成新的Pods。
* 回滚到前一个版本，如果当前版本不够稳定。每次回滚都会更新Deployment的版本号。
* 扩展Deployment以适应更高的负载。
* 暂停Deployment，将多个Fixes更新到PodTemplate中，然后再恢复Deployment，生成新的ReplicaSet.
* 将Deployment的状态（status）作为rollout是否stuck的指示器。
* 清理不再需要的旧的ReplicaSets。

## Deployment的创建
 下例会创建一个ReplicaSet部署3个nginx Pods。
  
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
执行如下命令可以发现Deployment rollout status：

```sh
$ kubectl rollout status deployment/nginx-deployment
Waiting for rollout to finish: 2 out of 3 new replicas have been updated...
deployment "nginx-deployment" successfully rolled out

```
## Deployment的更新
当且仅当Deployment的pod template发生变化时，比如labels或者container images发生变化，才会触发一次rollout；其它的更新，比如scalling Deployment，不会触发rollout。

```yaml
$ kubectl get deployments
NAME               DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
nginx-deployment   3         3         3            3           36s
```
* **up-to-date replicas**: updated the replicas to the latest configuration. 
* **current replicas**: the total replicas this Deployment manages
* **available replicas** : number of current replicas that are available.

当更新Pods的时候，Deployment可以确保只有一定数量的Pods处于down。默认是1；也可以确保只有一定数量的Pods超过desired number，默认也是1。
## Deployment的回滚
有时候，我们希望回滚Deployment，比如，Deployment不稳定，一直crash looping。默认会保留Deployment所有的rollout历史，可以回滚到任何时间点。

查看Deployment所有的rollout

```sh
kubectl rollout history deployment/nginx-deployment
deployments "nginx-deployment"
REVISION    CHANGE-CAUSE
1           kubectl create -f docs/user-guide/nginx-deployment.yaml --record
2           kubectl set image deployment/nginx-deployment nginx=nginx:1.9.1
3           kubectl set image deployment/nginx-deployment nginx=nginx:1.91
```

查看详情

```sh
$ kubectl rollout history deployment/nginx-deployment --revision=2
deployments "nginx-deployment" revision 2
  Labels:       app=nginx
          pod-template-hash=1159050644
  Annotations:  kubernetes.io/change-cause=kubectl set image deployment/nginx-deployment nginx=nginx:1.9.1
  Containers:
   nginx:
    Image:      nginx:1.9.1
    Port:       80/TCP
     QoS Tier:
        cpu:      BestEffort
        memory:   BestEffort
    Environment Variables:      <none>
  No volumes.
```

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

## Deployment的扩展
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

## Deployment的暂停和恢复
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

## Deployment的状态

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


## Deployment的清理策略
可以设置**.spec.revisionHistoryLimit**指定Deployment保存多少历史的ReplicaSets；其它的会在后台被清理掉。默认，所有的revision history将会被保存。

***如果设置为0，会clean up all the history of your Deployment, thus that Deployment will not be able to roll back.***








