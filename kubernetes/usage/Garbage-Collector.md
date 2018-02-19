# Garbage Collection
Kubernetes garbage collector的作用是删除某些没有owner的objects。

## Owners and dependents
一些Kubernetes objects事其它objects的owner。比如，ReplicaSet是一些Pods的owner。Owned objects被称为dependents of the owner object。每一个dependent object拥有一个metadata.ownerReferences字段指向它的owning object。

有时候，Kubernetes自动设置ownerReference。我们也可以通过手工来设置owners和dependents之间的关系。

``` yaml
apiVersion: extensions/v1beta1
kind: ReplicaSet
metadata:
  name: my-repset
spec:
  replicas: 3
  selector:
    matchLabels:
      pod-is-for: garbage-collection-example
  template:
    metadata:
      labels:
        pod-is-for: garbage-collection-example
    spec:
      containers:
      - name: nginx
        image: nginx
```

## 控制garbage collector如何删除dependents
当删除object的时候，可以指定是否自动删除它的dependents。 自动删除dependents称为**级联删除**。级联删除有两种模式：background和foreground.

如果删除object时没有自动删除它的dependents，那些dependents成为orphaned。

**Background cascading deletion**

Kubernetes立即删除owner object；Garbage collector后台删除dependents objects。

**Foreground cascading deletion**
The root object首先进入“deletion in progress”状态。在“deletion in progress”状态，下面条件成立：

* 对象仍然通过REST API可见
* 对象的deletionTimestamp被设置
* 对象的metadata.finalizers包含值“foregroundDeletion“

一旦“deletion in progress”状态被设置，garbage collector删除该object的dependents。一旦garbage collector删除所有的“blocking” dependents（objects with ownerReference.blockOwnerDeletion=true），立即删除owner object。

