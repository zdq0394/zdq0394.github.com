# ReplicaSet
ReplicaSet是Replication Controller的升级版。
它们之间仅有的不同点是**selector support**。

* ReplicaSet支持**set-based selector**
* Replication Controller仅支持**equality-based selector**.

## 如何使用ReplicaSet
尽管ReplicaSets可以独立使用。但是最佳点使用方式还是借助[Deployments](Deployments.md)实现对Pod对编排，包括创建、更新和删除。

使用Deployments，你不必担心如何管理deployment创建的ReplicaSet；Deployment拥有并且管理它们的ReplicaSet。

## When to use ReplicaSet
A ReplicaSet确保任何时刻都有指定数量的Pod处于running状态。Deployment是一个更高一层的概念，它可以管理ReplicaSet并且提供以声明式（**declarative**）对Pod进行更新。

所以，我们推荐使用**Deployments** 而不是直接使用ReplicaSets。

## 例子
``` yaml

apiVersion: extensions/v1beta1
kind: ReplicaSet
metadata:
  name: frontend
  # these labels can be applied automatically
  # from the labels in the pod template if not set
  # labels:
    # app: guestbook
    # tier: frontend
spec:
  # this replicas value is default
  # modify it according to your case
  replicas: 3
  # selector can be applied automatically
  # from the labels in the pod template if not set,
  # but we are specifying the selector here to
  # demonstrate its usage.
  selector:
    matchLabels:
      tier: frontend
    matchExpressions:
      - {key: tier, operator: In, values: [frontend]}
  template:
    metadata:
      labels:
        app: guestbook
        tier: frontend
    spec:
      containers:
      - name: php-redis
        image: gcr.io/google_samples/gb-frontend:v3
        resources:
          requests:
            cpu: 100m
            memory: 100Mi
        env:
        - name: GET_HOSTS_FROM
          value: dns
          # If your cluster config does not include a dns service, then to
          # instead access environment variables to find service host
          # info, comment out the 'value: dns' line above, and uncomment the
          # line below.
          # value: env
        ports:
        - containerPort: 80

```

## ReplicaSet as an Horizontal Pod Autoscaler target
A ReplicaSet可以成为Horizontal Pod Autoscalers (HPA)的Target,也就是说ReplicaSet可以通过HPA自动扩展伸缩。

``` yaml

apiVersion: autoscaling/v1
kind: HorizontalPodAutoscaler
metadata:
  name: frontend-scaler
spec:
  scaleTargetRef:
    kind: ReplicaSet
    name: frontend
  minReplicas: 3
  maxReplicas: 10
  targetCPUUtilizationPercentage: 50

```

