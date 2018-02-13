# 认证
## Kubernetes中的用户（users）
Kubernetes集群有**两种**类型的用户（users）。
* **Service accounts**：由kubernetes管理，可以通过API调用，比如kubectl命令，直接创建service accounts，并且service accounts会被绑定到一个namespace中。
* **normal users**：由外部独立的服务来管理，在kubernetes中没有相应的对象来描述normal user，也不能通过API调用添加normal user到kubernetes集群中。

一个API请求可以被：
* 一个normal user调用；
* 一个service account调用；
* 匿名调用。

## 认证策略
Kubernetes可以使用**client certificates**，**bearer tokens**，**authenticating proxy**，**HTTP basic auth**等方式来认证API请求。

当HTTP请求到达API Server的时候，authentication plugin尝试将下列属性关联到该请求上。
* Username： 用户名。通常的形式比如：kube-admin或者jane@example.com。
* UID： 代表end user的一个ID，比如Username更具有唯一性。
* Groups：用户所属的group列表。
* Extra： 用户的其他信息，授权系统或许会感兴趣

对于**认证**组件来说，这些值都没有特殊的含义。对后面的**授权**组件来说才是有意义的。

可以同时开启**多种认证策略**，至少包括如下2中：
* service account tokens for service accounts
* one method for normal user

如果同时启用了多个**认证**组件，第一个成功认证的组件将会阻止后面的组件继续认证。
API Server不能保证多个认证组件的执行顺序。

对任何认证通过的user，都会在user所属的groups列表中增加group **system:authenticated**。

### X509 Client Certs
启动API Server时，通过加入--client-ca-file=SOMEFILE可以开启Client certificate认证。
`SOMEFILE`必须包含一个或者多个证书，用来认证提供给API Server的client。

### Static Token File

### Bootstrap Tokens

### Static Password File

### Service Account Tokens

### OpenID Connect Tokens

### Webhook Token Authentication

### 认证代理（Authenticating Proxy）
API server可以配置成从HTTP Header中获取user信息，比如`X-Remote-User`。Kubernetes结合一个认证代理，认证代理拦截所有的API请求，认证通过之后，并设置相应的HTTP Header，然后将请求转发给API Server。

启动API Server时，可以添加如下flag：
* --requestheader-username-headers： 必须，不区分大小写。用来指出哪个HTTP Header包含用户的name信息。一般是`X-Remote-User`。
* --requestheader-group-headers： 1.6版本之后可选，不区分大小写。建议使用`X-Remote-Group`，所有的values作为user的group names。
* --requestheader-extra-headers-prefix： 1.6版本之后可选，不区分大小写。建议是用`X-Remote-Extra-`。

比如对于请求：
``` HTTP
GET / HTTP/1.1
X-Remote-User: fido
X-Remote-Group: dogs
X-Remote-Group: dachshunds
X-Remote-Extra-Scopes: openid
X-Remote-Extra-Scopes: profile
```
将产生一个user info：
```yaml
name: fido
groups:
- dogs
- dachshunds
extra:
  scopes:
  - openid
  - profile
```

### Keystone Password

## 匿名请求

## User impersonation（扮演）




