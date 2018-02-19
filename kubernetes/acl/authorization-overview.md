# Authorizatioin Overview
在Kubernetes集群中，一个请求在`授权`之前必须先`登陆`，经过`认证`之后，才能进入授权阶段。

## Determine Whether a Request is Allowed or Denied
Kubernetes使用API Server对API请求授权。
All parts of an API request must be allowed by some policy in order to proceed。
Kubenetes的默认是**拒绝授权**的。

如果配置了多个**授权模块**，将按照顺序进行检验。
对一个API请求，如果其中一个授权模块明确的approve或者deny，那么整个授权阶段将直接做出决定，而**无需**其它的授权模块对API请求继续检验。
如果所有的授权模块都没有明确的approve/deny，那么授权阶段将**拒绝请求**，返回403。

## Review Your Request Attributes
Kubernetes检查如下的API请求的属性。
* user  认证阶段提供的user字符串。
* group  认证阶段提供的user所属的list of groups。
* extra  认证阶段提供的额外的key-value对，map[string]string类型。
* API  指出该请求是否是针对一个API资源的。
* Request path  non-resource endpoints的路径，比如`/api`或者`/healthz`。
* API request verb  API verbs，比如`get`，`list`，`create`，`update`，`patch`，`watch`，`proxy`，`redirect`，`delete`和`deletecollection`；针对resource API endpoint。
* HTTP request verb  HTTP verbs，比如`get`，`post`，`put`，`delete`；针对non-resource endpoint。 
* Resource 请求的资源的ID或者name
* Subresource  请求的子资源
* Namespace  请求的对象的namespace
* API Group  请求的API的group

## Determine the Request Verb
对于一个resource API endpoint，它的Request Verb取决于HTTP verb和请求作用的对象是单个还是集合。
|    HTTP verb    | request verb |
| --------------- | ------------ |
| POST |  create |
| GET,HEAD  |  get(for individual), list(for collections) |
| PUT | update |
| PATCH | patch |
| DELETE | delete (for individual), list(for collections) |

## Authorization Modules
* [Node](authorization-node.md)
* [ABAC](authorization-abac.md)
* [RBAC](authorization-rbac.md)
* [Webhook](authorization-webhook.md)

