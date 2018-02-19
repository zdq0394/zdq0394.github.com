# DeamonSets

## 定义

A DaemonSet ensures that **all (or some) nodes run a copy of a pod**. 每当有节点加入集群时，都会在该节点上部署一个Pod。当节点离开集群时，该节点上的Pod也会被回收。

当删除DaemonSet时，将会删除它创建的所有Pods。

DaemonSet的典型应用场景：

* 在每个Node上运行集群存储daemon, such as glusterd, ceph
* 在每个Node上运行日志搜集daemon, such as fluentd or logstash.
* 在每个Node上运行监控daemon, such as Prometheus Node Exporter, collectd, Datadog agent, New Relic agent, or Ganglia gmond.

在简单的case中，一个DaemonSet覆盖所有的节点，运行各种类型的daemon。比较复杂的case中，使用多个DaemonSets运行一个daemon。

## DeamonSet的构建
### 创建一个DeamonSet
```yaml

apiVersion: extensions/v1beta1
kind: DaemonSet
metadata:
  name: fluentd-elasticsearch
  namespace: kube-system
  labels:
    k8s-app: fluentd-logging
spec:
  template:
    metadata:
      labels:
        name: fluentd-elasticsearch
    spec:
      containers:
      - name: fluentd-elasticsearch
        image: gcr.io/google-containers/fluentd-elasticsearch:1.20
        resources:
          limits:
            memory: 200Mi
          requests:
            cpu: 100m
            memory: 200Mi
        volumeMounts:
        - name: varlog
          mountPath: /var/log
        - name: varlibdockercontainers
          mountPath: /var/lib/docker/containers
          readOnly: true
      terminationGracePeriodSeconds: 30
      volumes:
      - name: varlog
        hostPath:
          path: /var/log
      - name: varlibdockercontainers
        hostPath:
          path: /var/lib/docker/containers

```

### 必需的Fields
和其它的Kubernetes config一样，一个DeamonSet需要**apiVersion**，**kind**和 **metadata**字段。
A DaemonSet也需要一个**.spec**节。

### Pod Template
**.spec.template**是**.spec**中唯一必需的字段。
**.spec.template**是一个**pod template**。它和Pod具有完全一样的Schema，除了它是嵌入的没有apiVersion和kind。

在DaemonSet中，Pod template除了必要的字段外，还必需指定**appropriate labels**。
Pod的**RestartPolicy**必须是**Always**。

### Pod Selector
### Running Pods on Only Some Nodes
如果指定了**.spec.template.spec.nodeSelector**，DaemonSet控制器将在指定的node上创建Pod。

## Pods的调度
正常情况下，Pod只会运行在Kubernetes调度器选中的节点上。然而，DaemonSet创建的Pod将会运行到所有节点上，忽略调度器。

Therefore:
* The unschedulable field of a node is not respected by the DaemonSet controller.
* **DaemonSet controller can make pods even when the scheduler has not been started**, which can help cluster bootstrap.

Daemon pods do respect taints and tolerations, but they are created with NoExecute tolerations for the following taints with no tolerationSeconds:

* node.alpha.kubernetes.io/notReady
* node.alpha.kubernetes.io/unreachable
* node.alpha.kubernetes.io/memoryPressure
* node.alpha.kubernetes.io/diskPressure

When the support to critical pods is enabled and the pods in a DaemonSet are labelled as critical, the Daemon pods are created with an additional NoExecute toleration for the node.alpha.kubernetes.io/outOfDisk taint with no tolerationSeconds.

This ensures that when the TaintBasedEvictions alpha feature is enabled, they will not be evicted when there are node problems such as a network partition. (When the TaintBasedEvictions feature is not enabled, they are also not evicted in these scenarios, but due to hard-coded behavior of the NodeController rather than due to tolerations).

## Communicating with Daemon Pods
下面是一些Some possible patterns for communicating with pods in a DaemonSet are:

* Push: Pods in the DaemonSet are configured to send updates to another service, such as a stats database. They do not have clients.
* NodeIP and Known Port: Pods in the DaemonSet can use a hostPort, so that the pods are reachable via the node IPs. Clients know the list of nodes ips somehow, and know the port by convention.
* DNS: Create a headless service with the same pod selector, and then discover DaemonSets using the endpoints resource or retrieve multiple A records from DNS.
* Service: Create a service with the same pod selector, and use the service to reach a daemon on a random node. (No way to reach specific node.)

## Updating a DaemonSet
如果一个node的label改变了，DaemonSet将会自动的在新匹配的节点上部署Pods或者在不匹配的节点上删除Pods。

可以改变Pod的部分字段。

可以删除daemonset，如果在删除时，指定参数--cascade=false，Pods将不会删除。

## DaemonSet的替代
* Init Scripts
* Bare Pods
* Static Pods
* Replication Controller




