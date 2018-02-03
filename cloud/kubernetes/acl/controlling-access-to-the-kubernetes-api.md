# Controlling Access to the Kubernetes API
用户可以通过如下方式访问api：
* kubectl
* client library
* making REST requests

访问API的主体可以是**human users**，也可以是**Kubernetes service accounts**。
当一个请求到达API时，会经历如下几个stage：

![](pics/access-control-overview.svg)

## Transport Security
在Kubernetes集群中，API通常监听端口443。
API Server提供一个certificate。这个Certificate通常是self-signed，所以用户机器上的$USER/.kube/config包含API Server的certificate的根certificate。当指定时，会用来代替用户系统的默认root certificate。

如果通过**kube-up.sh**创建集群，这个certificate会自动写入到$USER/.kube/config中。

如果集群有多个用户，那么需要将这个certificate分发给每个用户。

## Authentication
TLS连接建立之后，HTTP请求进入到认证阶段**Authentication Step**，图中step 1。
集群Admin可以配置多个认证模块（Authenticator modules）。

认证模块的输入是整个HTTP请求（entire HTTP request），然而，认证模块只会检查headers和client certificate。

Authentication模块包括：
* Client Certificate
* Password
* Plain Tokens
* Bootstrap Tokens
* JWT Tokens（Service Accounts）

可以指定多个authentication modules。请求会按照顺序经过authentication认证，直到其中一个认证成功。

如果HTTP Request不能被任何一个authentication module认证通过，请求被拒绝，返回401。

认证成功后，用户被认证为一个特殊的**username**，可以被后续的step使用。

尽管Kubernetes使用"username"作为访问控制、请求logging，Kubernetes没有一个`user`对象，也**没有**usernames或者user相关的信息存储到它的object store中。

## Authorization
请求认证之后，就进入了**授权阶段**(Authorization Step)。
一个请求必须包括：请求者的username，请求的动作（action）以及请求的对象（object affected by the action）。
如果存在一个Policy声明该user拥有权限完成请求的动作，则授权通过。

如下的policy文件说明**bob**可以**读取**空间**projectCaribou**中的**pods**。
```json
{
    "apiVersion": "abac.authorization.kubernetes.io/v1beta1",
    "kind": "Policy",
    "spec": {
        "user": "bob",
        "namespace": "projectCaribou",
        "resource": "pods",
        "readonly": true
    }
}
```
Kubernetes支持多个授权模块（authorization modules）：
* ABAC mode
* RBAC mode
* Webhook mode

当集群创建时，管理员需要配置API Server的授权modules。
如果配置了多个authorization modules，Kubernetes检查每个module，只要有一个module授权通过，则整个请求通过。
如果没有一个module可以授权通过，则请求被拒绝，返回**403**。

## Admission Control
Admission Control Modules是一个software modules，可以修改或拒绝请求。
除了授权模块可以使用的属性之外，Admission Control modules还可以访问对象的内容——正在创建、更新、删除或者connected(proxy)的对象，但是不能是读取的对象。

可以配置多个admission controller，每个按照顺序调用。如图中step 3所示。

与Authentication和Authorization不同，任何一个admission control module拒绝，整个请求被拒绝。

除了拒绝请求之外，admission controllers还可以设置字段的默认值。

一旦请求通过所有的admission controllers，它会由API Object相关的验证过程进行验证，然后写入到Kubernetes的object store中。