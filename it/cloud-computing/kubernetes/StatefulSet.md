# StatefulSets
A StatefulSet is a Controller that provides a unique identity to its Pods. 
It provides guarantees about the ordering of deployment and scaling.

## 使用场景
一些应用具有如下一个或多个要求：

* 稳定的唯一的网络标志（network identifiers）
* 稳定的持久的存储
* 有顺序的优雅的部署和扩展
* 有顺序的优雅的删除和终止
* 有顺序的自动的rolling updates

StatefulSets对这样的应用时非常有价值的。

## 使用限制

* Pod的存储要么是通过PersistVolume利用requested storage class，要么由admin提前创建好。
* Deleting and/or scaling a StatefulSet down 不会删除StatefulSet关联的存储卷。这样做时为了数据安全性。
* StatefulSets目前需要a Headless Service 负责Pods的network identity，Admin需要创建这个headless service。

## StatefulSets组件

* A Headless Service, named nginx, is used to control the network domain.
* The StatefulSet, named web, has a Spec that indicates that 3 replicas of the nginx container will be launched in unique Pods.
* The volumeClaimTemplates will provide stable storage using PersistentVolumes provisioned by a PersistentVolume Provisioner.

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
StatefulSet Pods拥有一个唯一的身份：一个序号， 一个稳定的network identity，和一个稳定的存储。这个身份附着于Pod，不论Pod调度到哪个节点上。
### Ordinal Index
一个拥有N个副本的StatefulSet，每个Pod都被分配一个唯一的序数[0,N)。
### Stable Network ID
StatefulSet中的Pod的hostname是由StatefulSet的name和Pod的序号组成的。

形式如：*** $(statefulset name)-$(ordinal) *** 。 

上例将创建3个Pods：web-0,web-1,web-2。

A StatefulSet利用Headless Service控制Pod的域名。

Headless services管理的域名：$(service name).$(namespace).svc.cluster.local，“cluster.local”是集群的余名。

每个Pod分配一个子域名：$(podname).$(governing service domain)，governing service由StatefulSet的Service定义。

| Cluster Domain | Service(ns/name) | StatefulSet(ns/name) | StatefulSe Domain | Pod DNS | Pod Hostname |
| ------ | ------- | ------ | ------ | ------ | ------ |
| cluster.local | default/nginx | default/web | nginx.default.svc.cluster.local | web-{0..N-1}.nginx.default.svc.cluster.local | web-{0..N-1} |
| cluster.local | foo/nginx | foo/web | nginx.foo.svc.cluster.local | web-{0..N-1}.nginx.foo.svc.cluster.local | web-{0..N-1} |
| kube.local | foo/nginx | foo/web | nginx.foo.svc.kube.local | web-{0..N-1}.nginx.foo.svc.kube.local | web-{0..N-1} |

### Stable Storage

Kubernetes creates one PersistentVolume for each VolumeClaimTemplate。

In the nginx example above, **each Pod will receive a single PersistentVolume with a StorageClass of my-storage-class and 1 Gib of provisioned storage** 。

If no StorageClass is specified, then the default StorageClass will be used. 

When a Pod is (re)scheduled onto a node, its volumeMounts mount the PersistentVolumes associated with its PersistentVolume Claims. 

Note that, the PersistentVolumes associated with the Pods’ PersistentVolume Claims are not deleted when the Pods, or StatefulSet are deleted. 

**This must be done manually**。

## Deployment and Scaling Guarantees

* StatefulSet with N replicas，当部署Pods时，必须严格按照顺序创建： {0..N-1}.
* 当Pods删除时，严格按照**倒序**删除：{N-1..0}.
* 当一个Pod执行scalling时，所有序号在它之前的确保处于Running和Ready。
* 当一个Pod被销毁时，所有序号在它之后的确保已经shutdown。

The StatefulSet**从不指定**a pod.Spec.TerminationGracePeriodSeconds of 0。
这个配置不安全，应当强烈避免。

When the nginx example above is created, three Pods will be deployed in the order web-0, web-1, web-2. web-1 will not be deployed before web-0 is Running and Ready, and web-2 will not be deployed until web-1 is Running and Ready. If web-0 should fail, after web-1 is Running and Ready, but before web-2 is launched, web-2 will not be launched until web-0 is successfully relaunched and becomes Running and Ready。


If a user were to scale the deployed example by patching the StatefulSet such that replicas=1, web-2 would be terminated first. web-1 would not be terminated until web-2 is fully shutdown and deleted. If web-0 were to fail after web-2 has been terminated and is completely shutdown, but prior to web-1’s termination, web-1 would not be terminated until web-0 is Running and Ready.

### Pod Management Policies
In Kubernetes 1.7 and later, StatefulSet allows you to relax its ordering guarantees while preserving its uniqueness and identity guarantees via its .spec.podManagementPolicy field.

* OrderedReady Pod Management

OrderedReady pod management is the default for StatefulSets. It implements the behavior described above.

* Parallel Pod Management

Parallel pod management tells the StatefulSet controller to launch or terminate all Pods in parallel, and to not wait for Pods to become Running and Ready or completely terminated prior to launching or terminating another Pod.

## Update Strategies
In Kubernetes 1.7 and later, StatefulSet’s .spec.updateStrategy field allows you to configure and disable automated rolling updates for containers, labels, resource request/limits, and annotations for the Pods in a StatefulSet.
### On Delete
The OnDelete update strategy implements the legacy (1.6 and prior) behavior. It is the default strategy when spec.updateStrategy is left unspecified. 

When a StatefulSet’s .spec.updateStrategy.type is set to OnDelete, **the StatefulSet controller will not automatically update the Pods in a StatefulSet**. 

Users must manually delete Pods to cause the controller to create new Pods that reflect modifications made to a StatefulSet’s .spec.template.

###Rolling Updates
The RollingUpdate update strategy implements automated, rolling update for the Pods in a StatefulSet. 

When a StatefulSet’s .spec.updateStrategy.type is set to RollingUpdate, the StatefulSet controller will delete and recreate each Pod in the StatefulSet. It will proceed in the same order as Pod termination (from the largest ordinal to the smallest), updating each Pod one at a time. 

It will wait until an updated Pod is Running and Ready prior to updating its predecessor.

## Partitions

The RollingUpdate update strategy can be partitioned, by specifying a .spec.updateStrategy.rollingUpdate.partition. 

If a partition is specified, all Pods with an ordinal that is greater than or equal to the partition will be updated when the StatefulSet’s .spec.template is updated. 

All Pods with an ordinal that is less than the partition will not be updated, and, even if they are deleted, they will be recreated at the previous version. 

If a StatefulSet’s .spec.updateStrategy.rollingUpdate.partition is greater than its .spec.replicas, updates to its .spec.template will not be propagated to its Pods. 

In most cases you will not need to use a partition, but they are useful if you want to stage an update, roll out a canary, or perform a phased roll out.



