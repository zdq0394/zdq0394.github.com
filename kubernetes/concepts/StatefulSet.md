# StatefulSets
StatefulSet对其管理的每个Pod都维持一个唯一的，sticky identity。通过此种方式管理Pods集合的部署和扩展，并对Pods提供**顺序保证**。

和Deployments一样，StatefulSets基于一个同样的container spec来管理Pods。不过，尽管它们的Spec是一样的，StatefulSet中的Pods却是不能交换的（interchangeable）。每个Pod都拥有一个持久的标志符（identifier），可以支持重新调度。

StatefulSets也是通过控制器模式进行操作和管理。我们可以在StatefulSet对象中定义期望的状态（desired state）。StatefulSet控制器通过进行必要的更新以达到期望的状态。
## 使用场景
一些应用具有如下一个或多个要求：

* 稳定的唯一的网络标志（network identifiers）
* 稳定的持久的存储
* 有顺序的优雅的部署和扩展
* 有顺序的优雅的删除和终止
* 有顺序的自动的rolling updates

上面的语义中，**stable**和**persistence across Pod (re)scheduling**是同义词。
StatefulSets对这样的应用时非常有价值的。

## 使用限制

* Pod的存储要么是通过PersistVolume利用requested storage class，要么由admin提前创建好。
* Deleting and/or scaling a StatefulSet **down** 不会删除StatefulSet关联的**存储卷**。这样做时为了数据安全性。
* StatefulSets目前需要一个Headless Service负责Pods的network identity，Admin需要创建这个headless service。

## StatefulSets组件

下面是一个StatefulSet的例子：

* A **Headless Service**, named nginx, is used to control the network domain.
* The **StatefulSet**, named web, has a Spec that indicates that 3 replicas of the nginx container will be launched in unique Pods.
* The **volumeClaimTemplates** will provide stable storage using PersistentVolumes provisioned by a PersistentVolume Provisioner.

``` yaml

apiVersion: v1
kind: Service
metadata:
  name: nginx
  labels:
    app: nginx
spec:
  ports:
  - port: 80
    name: web
  clusterIP: None
  selector:
    app: nginx
---
apiVersion: apps/v1beta1
kind: StatefulSet
metadata:
  name: web
spec:
  serviceName: "nginx"
  replicas: 3
  template:
    metadata:
      labels:
        app: nginx
    spec:
      terminationGracePeriodSeconds: 10
      containers:
      - name: nginx
        image: gcr.io/google_containers/nginx-slim:0.8
        ports:
        - containerPort: 80
          name: web
        volumeMounts:
        - name: www
          mountPath: /usr/share/nginx/html
  volumeClaimTemplates:
  - metadata:
      name: www
    spec:
      accessModes: [ "ReadWriteOnce" ]
      storageClassName: my-storage-class
      resources:
        requests:
          storage: 1Gi

```

## Pod Identity
StatefulSet Pods拥有一个唯一的身份，由3部分组成：**一个序号**， **一个稳定的network identity**，和**一个稳定的存储**。这个身份附着于Pod，不论Pod调度到哪个节点上。
### Ordinal Index
一个拥有N个副本的StatefulSet，每个Pod都被分配一个唯一的序数[0,N)。
### Stable Network ID
StatefulSet中的Pod的hostname是由**StatefulSet的name**和**Pod的序号**组成的。

形式如：***$(statefulset name)-$(ordinal)*** 。 

上例将创建3个Pods：web-0,web-1,web-2。

A StatefulSet利用**Headless Service**控制**Pod的域**。

Headless services管理的域名：**$(service name).$(namespace).svc.cluster.local** 

“cluster.local”是集群的域名。

每个Pod分配一个子域名：**$(podname).$(governing service domain)**，governing service由StatefulSet的Service定义。


| Cluster Domain | Service(ns/name) | StatefulSet(ns/name) | StatefulSe Domain | Pod DNS | Pod Hostname |
| ------ | ------- | ------ | ------ | ------ | ------ |
| cluster.local | default/nginx | default/web | nginx.default.svc.cluster.local | web-{0..N-1}.nginx.default.svc.cluster.local | web-{0..N-1} |
| cluster.local | foo/nginx | foo/web | nginx.foo.svc.cluster.local | web-{0..N-1}.nginx.foo.svc.cluster.local | web-{0..N-1} |
| kube.local | foo/nginx | foo/web | nginx.foo.svc.kube.local | web-{0..N-1}.nginx.foo.svc.kube.local | web-{0..N-1} |

### Stable Storage

Kubernetes为每个VolumeClaimTemplate创建一个PersistentVolume。

在上例中，**each Pod will receive a single PersistentVolume with a StorageClass of my-storage-class and 1 Gib of provisioned storage** 。

如果没有指定StorageClass将使用default StorageClass。 

当一个Pod调度或者重新调度一个节点时，它的volumeMounts将 mount the PersistentVolumes associated with its PersistentVolume Claims。

注意：当Pods或者StatefulSet删除时，不会删除the PersistentVolumes associated with the Pods’ PersistentVolume Claims。

**This must be done manually**。

## Deployment and Scaling Guarantees

* StatefulSet with N replicas，当部署Pods时，必须严格按照顺序创建： {0..N-1}.
* 当Pods删除时，严格按照**倒序**删除：{N-1..0}.
* 当一个Pod执行scalling时，所有序号在它之前的确保处于Running和Ready。
* 当一个Pod被销毁时，所有序号在它之后的确保已经shutdown。

The StatefulSet**从不指定**a pod.Spec.TerminationGracePeriodSeconds of 0。
这个配置不安全，应当强烈避免。

### Pod Management Policies
Kubernetes 1.7+版本中，StatefulSet允许放松对顺序的保证。通过**.spec.podManagementPolicy field**实现。

* **OrderedReady Pod Management**

OrderedReady pod management is the default for StatefulSets. It implements the behavior described above.

* **Parallel Pod Management**

Parallel pod management tells the StatefulSet controller to launch or terminate all Pods in parallel, and to not wait for Pods to become Running and Ready or completely terminated prior to launching or terminating another Pod.

## 更新策略
Kubernetes 1.7+，StatefulSet’s .spec.updateStrategy field allows you to configure and disable automated rolling updates for containers, labels, resource request/limits, and annotations for the Pods in a StatefulSet.
### On Delete
这是默认值。**the StatefulSet controller will not automatically update the Pods in a StatefulSet**. 

用户必须手动删除Pods以使得控制器按照更新后的template创建新的Pods。

###Rolling Updates
自动的滚动的更新。 


