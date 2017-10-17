# kubernetes 系统资源限制和配额
资源隔离和限制，这是PaaS的基础能力。

Kubernetes对资源的隔离和限制体现在三个层次：

1. Namespace
2. Pod
3. Container

## Namespace层次的限制
针对一个namespace可以添加一个**ResourceQuota**，对其可以使用的资源进行限制。

首先创建一个namespace: quota-example

```yaml

apiVersion: v1
kind: Namespace
metadata:
  name: quota-example

```

默认情况下namespace是没有资源配额的，现在给namespace设置配额。

```yaml

apiVersion: v1
kind: ResourceQuota
metadata:
    name: quota-example
    namespace: quota-example
spec:
    hard:
        requests.cpu: "2"
        requests.memory: 2Gi
        limits.cpu: "20"
        limits.memory: 20Gi
        persistentvolumeclaims: "10"
        pods: "10"
        replicationcontrollers: "1"
        secrets: "10"
        services: "5"

```

查看namespace的配额和使用情况

``` sh

$ kubectl describe quota quota-example -n quota-example
Name:			        quota-example
Namespace:		        quota-example
Resource		        Used	Hard
--------		        ----	----
cpu			            0 	    20
memory			        0	    1Gi
persistentvolumeclaims	0	    10
pods			        0	    10
replicationcontrollers	0	    1
secrets			        1	    10
services		        0	    5

```

创建一个nginx Pod

``` yaml

apiVersion: v1
kind: Pod
metadata:
    name: nginx
    namespace: quota-example
    labels:
        name: nginx
spec:
    containers:
    - name: nginx
      image: nginx

```
``` sh

$ kubectl create -f pod_nignx.yaml 
Error from server (Forbidden): error when creating "pod_nignx.yaml": pods "nginx" is forbidden: failed quota: quota-example: must specify cpu,memory

```
因为Pod没有进行资源限制，所有namesapce quota-example中的ResourceQuota拒绝在该namespace进行pod创建。

## Pod和Container层次的资源限制

### 通过LimitRange实现对namespace中container和pod资源的限制

``` yaml

apiVersion: v1
kind: LimitRange
metadata:
    name: quota-example
    namespace: quota-example
spec:
    limits:
    - max:
        cpu: "2"
        memory: 1Gi
      min:
        cpu: 250m
        memory: 6Mi
      type: Pod
    - max:
        cpu: "2"
        memory: 1Gi
      min:
        cpu: 250m
        memory: 6Mi
      default:
        cpu: 500m
        memory: 100Mi
      defaultRequest:
        cpu: 250m
        memory: 80Mi
      type: Container

```

然后可以成功创建nginx pod.

``` sh

$ kubectl create -f pod_nignx.yaml 
pod "nginx" created

```

### 创建Pod时指定Resources.limits
LimitRange时namespace范围内，创建pod时的默认值，也可以在创建Pod时自定义值。

```yaml

apiVersion: v1
kind: Pod
metadata:
    name: nginx
    namespace: quota-example
    labels:
        name: nginx
spec:
    containers:
    - name: nginx
      image: nginx
      resources:
        limits:
          cpu: 100m
          memory: 100Mi

```

## limitrange

* If the Container does not specify its own CPU request and limit, assign the default CPU request and limit to the Container.
* Verify that the Container specifies a CPU request that is greater than or equal to 200 millicpu.
* Verify that the Container specifies a CPU limit that is less than or equal to 800 millicpu.