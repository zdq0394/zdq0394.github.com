# Namespaces
Kubernetes支持在一个物理集群上构建多个虚拟集群。虚拟集群的构建方式是**namespaces**。

## When to Use Multiple Namespaces
Namespaces的使用场景是kubernetes集群用来服务很多用户，并且这些用户来自不同的teams/projects。
如果只有几个或者十多个用户，不需要使用namespaces。

Namespaces为names提供了作用域。
资源的names在一个namespace内部是unique的，跨namespaces不需要unique。

在Kubernetes以后的版本中，同一个namespace中的objects将默认拥有相同的访问控制策略。

对于只有一些很小的不同的资源，比如不同版本的软件，不必使用namespaces；可以在同一个namespace中，使用labels进行区分。

## Working with namespaces

### Viewing namespaces
可以使用如下命令列出当前集群存在的namespaces：
``` sh
$ kubectl get namespaces
NAME          STATUS    AGE
default       Active    1d
kube-system   Active    1d
kube-public   Active    1d
```

Kubernetes初始拥有3个namespaces：
* default： 没有明确指定namespace的objects都默认术语default namespace。
* kube-system： Kubernetes system创建的objects所有的namespace。
* kube-public： 该namespace是自动创建的，并且可以被所有的user（包括没有认证的用户）访问。该namespace主要保留给cluster使用，一些资源应该对整个集群可见。 该namespace的public是惯例，不是必需。

### Setting the namespace for a request
为一个请求临时设置namespace，可以通过--namespace：
```sh
kubectl --namespace=<insert-namespace-name-here> get pods
```

### Setting the namespace preference
可以通过如下命令，为后来的kubectl命令设置永久的namespace。
```sh
$ kubectl config set-context $(kubectl config current-context) --namespace=<insert-namespace-name-here>
# Validate it
$ kubectl config view | grep namespace:
```

## Namespaces and DNS
当创建一个service时，就会相应创建一个DNS entry。
DNS entry具有如下形式：
```
<service-name>.<namespace-name>.svc.cluster.local
```
这就是说，如果一个容器直接使用service-name，将会解析到当前容器所属的namespace中的服务。

如果要跨namespaces访问服务的话，就需要使用Fully Qualified Domain Name。

## Not All Objects are in a Namespace
大多数Kubernetes resources，比如pods，services，replication controllers等都属于某个namespaces。

不过，namespace本身并不属于它自己的namespace。

还有一些low-level的资源，比如nodes，persistentVolumes也不属于任何namespace。

Events是个例外：这主要取决于events相关的objects是否属于某个namespace。


