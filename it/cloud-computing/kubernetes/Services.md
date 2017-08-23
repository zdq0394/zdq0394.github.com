# Services
Kubernetes Pods不是持久的（are mortal），并且无法被恢复。虽然Pod失败之后会被控制器（比如ReplicationController/ReplicaSet）重启，但这是一个全新的POD，关键是POD的IP发生了变化。那么该POD提供给的服务就无法直接被外部依赖。
为此，Kubernetes引入了Service.

A Kubernetes Service is an abstraction which defines a logical set of Pods and a policy by which to access them - sometimes called 微服务（a micro-service）。

The set of Pods targeted by a Service is(usually) determined by a ***Label Selector***。这样当外界访问Pod提供的服务时，不必直接访问Pod本身，可以通过Service来访问。Services的IP在生命周期中时不变的，实现了对后端Pod的代理。尽管实际提供服务的Pods会发生变化，但是前端不需要关心。Services作为中间层实现了解耦。

1. For Kubernetes-native applications, Kubernetes offers a simple **Endpoints API** that is updated whenever the set of Pods in a Service changes. 
2.  For non-native applications, Kubernetes offers a **virtual-IP-based bridge to Services** which redirects to the backend Pods.

## 概念
A Service in Kubernetes is a **REST object**. 
For example, suppose you have **a set of Pods** that each expose port 9376 and carry a label "app=MyApp".

	kind: Service
	apiVersion: v1
	metadata:
	  name: my-service
	spec:
	  selector:
	    app: MyApp
	  ports:
	    - protocol: TCP
	      port: 80
	      targetPort: 9376

这个服务会被分配一个服务IP（ClusterIP）。**Service Proxies**将使用这个IP，转发请求。 集群会持续的评估Service’s selector，并将结果Posted到和服务同名的Endpoints。

## Service without Selectors

Service可以没有selectors.

Services通常抽象代理对Kubernetes Pods的访问，其实也可以代理对其他后端服务的访问。

* You want to have an external database cluster in production, but in test you use your own databases.
* You want to point your service to a service in another Namespace or on another cluster.
* You are migrating your workload to Kubernetes and some of your backends run outside of Kubernetes.

通过如下yaml可以定义service without selector

``` yaml

kind: Service
apiVersion: v1
metadata:
  name: my-service
spec:
  ports:
    - protocol: TCP
      port: 80
      targetPort: 9376

```

由于这个service没有selector，相应的Endpoints不会自动创建，我们可以人工创建指定的endpoints：

``` yaml

kind: Endpoints
apiVersion: v1
metadata:
  name: my-service
subsets:
  - addresses:
      - ip: 1.2.3.4
    ports:
      - port: 9376

```


Endpoint IPs may **NOT** be **loopback (127.0.0.0/8)**, **link-local (169.254.0.0/16)**, or **link-local multicast (224.0.0.0/24)** 。

访问service（无selector）和service（有selector）没有什么不同，流量会重定向到后端的endpoints。


## ExternalName Services

An **ExternalName service**是一种特殊的没有selector的服务。它不需要定义endpoints。它仅仅是返回一个**外部服务**的别名。 外部服务是相对于Kubernetes集群而言的。

``` yaml

kind: Service
apiVersion: v1
metadata:
  name: my-service
  namespace: prod
spec:
  type: ExternalName
  externalName: my.database.example.com

```
当查找my-service.prod.svc.CLUSTER时，集群DNS返回一个CNAME记录：my.database.example.com

## Virtual IPs and Service Proxies

Kubernetes集群中每个节点都运行组件**kube-proxy**。Kube-proxy负责为服务（ExternalName类型的服务除外）提供VIP。

### Proxy-mode: userspace
Kube-proxy通过apiServer监控services和endpoints的添加和删除。当有新的service添加时：
1. Kube-proxy在本地节点上打开一个随机的端口
2. 添加iptables规则，将service ClusterIP的流量转到1中打开的port
3. Kube-proxy监听从1中端口过来的流量，然后通过一定的策略转发到支持service的Endpoints。

![](pics/services-userspace-overview.svg)


### Proxy-mode: iptables
Kube-proxy通过apiServer监控services和endpoints的添加和删除。当有新的service添加时：
1. Kube-proxy添加iptables规则，将service ClusterIP的流量转到一个随机的pod上。
也就是说，对任何一个endpoints，它添加一个iptables规则，将流量转到某个具体endpoint上。

![](pics/services-iptables-overview.svg)

### 对比

* iptables方式更快，更可靠；但是不够灵活
* userspace方式，当某个pod出问题时，可以自动切换到其它的pod

## 服务发现
### 环境变量
当一个Pod在节点上运行的时候，针对每一个服务service，Kubelet都会添加一组环境变量。
环境变量的格式如下：

``` yaml

  {SVCNAME}_SERVICE_HOST and {SVCNAME}_SERVICE_PORT

```
其中服务的名字都是**大写**，并且**短线转换为下划线**。

使用环境变量有个限制：Pod使用的服务必须在Pod之前创建，否则环境变量为空。使用DNS进行服务发现没有这个限制。

### DNS
Cluster DNS Server为每个服务添加DNS record. [DNS](DNS-Pods-and-Services.md)


## Headless Services
如果不需要做负载均衡和一个Service IP，可以创建一个headless services。创建headless services的方式是指定spec.clusterIP:None。

这样的服务没有CLuster IP，Kube-proxy不会处理这样的services。平台不会做负载均衡，没有Proxying。DNS还是有的。DNS的设置取决于是否有selectors

##服务发布

可以通过ServiceType指定service的类型，默认的服务类型时ClusterIP。

* ClusterIP：服务发布在一个内部IP(cluster-internal)ip上，也就是ClusterIP上。服务只能在集群内访问。
* NodePort：服务发布在每个节点及其固定的Port上。ClusterIP服务会自动建立，Nodeport会路由到ClusterIP上。可以从外部访问。
* LoadBalancer：服务发布到外部的负载均衡器上。NodePort service和ClusterIP services会自动建立。
* ExternalName：服务会映射到一个外部服务上。


