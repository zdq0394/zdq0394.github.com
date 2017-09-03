# Cron Jobs
## 概念
A Cron Job管理基于时间的Jobs:

* 仅某个时间点执行一次
* 在某个时间点重复执行

CronJob类似于crontab中的一个任务（其中的一行）。

## CronJob的创建
下面是一个简单的CronJob。每隔一分钟，它运行一个简单的Job：输出当前时间和"hello"。

```yaml
apiVersion: batch/v2alpha1
kind: CronJob
metadata:
  name: hello
spec:
  schedule: "*/1 * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: hello
            image: busybox
            args:
            - /bin/sh
            - -c
            - date; echo Hello from the Kubernetes cluster
          restartPolicy: OnFailure
```

## CronJob的删除

**删除CronJob**

`` sh 
$ kubectl delete cronjob hello
cronjob "hello" deleted
``

此时不会有新的Jobs产生，但是正在运行的Jobs不会停止，关联的Pods也不会删除。清理剩余的资源，需要找出所有的Job，然后手动删除。

**查看CronJob关联的Jobs并删除**

```
$ kubectl get jobs
NAME               DESIRED   SUCCESSFUL   AGE
hello-1201907962   1         1            11m
hello-1202039034   1         1            8m
...

$ kubectl delete jobs hello-1201907962 hello-1202039034 ...
job "hello-1201907962" deleted
job "hello-1202039034" deleted
```

## CronJob的Limitions
一个cron job每个执行周期**大约**创建一个Job。我们说**大约**意思是在某些条件下可能会创建两个Job或者0个Job。


