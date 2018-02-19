# Kubernetes API概念
Kubernetes API是一个通过`HTTP`提供的基于资源的（`RESTful`）的编程接口：
支持通过标准的HTTP请求（POST, PUT, PATCH, DELETE, GET）查询、创建、更新和删除主要资源；
支持子资源：可以进行更细粒度的授权；
支持以多种格式（JSON, Protobuf）接收和展示资源；
支持变更通知：其他组件可以通过`watches`和`consistent lists`高效的缓存和同步资源的状态。

## 标准API术语
大部分的Kubernetes API资源类型都是`objects`——它们代表一个集群中一个具体概念，比如`pod`和`namespace`；
一小部分API资源类型是`virtual`——它们代表操作而不是对象，比如`权限检查`（SubjectAccessReview）。

所有的`objects`都具有一个唯一的名字，支持幂等的创建和查询；但是`virtual`类型的资源如果不支持查询/非幂等的话，可能没有唯一的名字。

总体上，Kubernetes使用标准的RESTful术语描述API概念：
* `resource type`是URL中使用的名字（pods/namespaces/services）
* 所有的资源类型拥有一个具体的JSON表示（在schema中，`kind`）
* 某种类型的资源集合称为`collection`
* 某种类型的单个资源称为`resource`

### Cluster scoped resources
* 资源路径一般是：`/apis/GROUP/VERSION/*`
* 获取资源集合：`/apis/GROUP/VERSION/RESOURCETYPE`
* 获取单个资源：`/apis/GROUP/VERSION/RESOURCETYPE/NAME`
* 获取Subresource： `/apis/GROUP/VERSION/RESOURCETYPE/NAME/SUBRESOURCE`


### Namespace scoped resources
对于该资源类型，当namespace被删除后，namespace作用域的所有的资源类型也被删除。

* 资源路径一般是：`/apis/GROUP/VERSION/namespaces/NAMESPACE/*`
* 获取所有namespaces的资源集合： `/apis/GROUP/VERSION/RESOURCETYPE`
* 获取某个namespace的资源集合：`/apis/GROUP/VERSION/namespaces/NAMESPACE/RESOURCETYPE`
* 获取某个namespace的单个资源：`/apis/GROUP/VERSION/namespaces/NAMESPACE/RESOURCETYPE/NAME`
* 获取Subresource：`/apis/GROUP/VERSION/namespaces/NAMESPACE/RESOURCETYPE/NAME/SUBRESOURCE`

## Efficient detection of changes
客户端可以构建一个模型（model）来表示集群的当前状态(current state of a cluster)。
Kubernetes资源类型必须支持`consistent list`和`incremental change notification`。
每个Kubernetes对象包含一个`resourceVersion`字段，表示存储在底层数据中的资源的版本。
当获取一个资源集合的时候，无论是集群还是namespace范围内的资源，服务器的响应将包含一个`resourceVersion`字段，可以用来初始化一个`watch`。服务器将返回`resourceVersion`之后的所有变更（creates, deletes, updates）。
这样允许客户端获取当前集群的状态，并监控所有的变更。

如果客户端断开了连接，它可以从上次返回的`resourceVersion`开始，重启一个新的`watch`。

**例子**

1. list `test` namespace下的所有pods。
```json
 GET /api/v1/namespaces/test/pods
 ---
 200 OK
 Content-Type: application/json
 {
   "kind": "PodList",
   "apiVersion": "v1",
   "metadata": {"resourceVersion":"10245"},
   "items": [...]
 }
```
2. 从resource version 10245开始接收所有的变更通知。
```json
GET /api/v1/namespaces/test/pods?watch=1&resourceVersion=10245
 ---
 200 OK
 Transfer-Encoding: chunked
 Content-Type: application/json
 {
   "type": "ADDED",
   "object": {"kind": "Pod", "apiVersion": "v1", "metadata": {"resourceVersion": "10596", ...}, ...}
 }
 {
   "type": "MODIFIED",
   "object": {"kind": "Pod", "apiVersion": "v1", "metadata": {"resourceVersion": "11020", ...}, ...}
 }
 ...
```

* 旧的Kubernetes cluster 使用`etcd2`最多保存1000个变更；
* 新的Kubernetes cluster 使用`etcd3`最长保存5分钟的变更；

如果客户端的`watch`请求已经过期的资源，将返回`410 gone`；客户端此时需要重新`list`，然后根据返回的`resourceVersion`再次进行`watch`。


## Retrieving large results sets in chunks
对于一个大型的集群，获取某种类型的资源集合会产生一个非常大的response，这会对客户端和服务器都产生极大的影响。

从1.9开始，Kubernetes支持把一个大的请求的响应拆分成多个小的`chunks`，同时保持整个请求的`一致性`。[详情](https://kubernetes.io/docs/reference/api-concepts/#retrieving-large-results-sets-in-chunks)

## Alternate representations of resources
Kubernetes默认接受和返回`json`格式的数据。也可以支持`Protobuf`：[application/vnd.kubernetes.protobuf](https://kubernetes.io/docs/reference/api-concepts/#alternate-representations-of-resources)


