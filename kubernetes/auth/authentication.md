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

当HTTP请求到达API Server的时候，authentication plugin尝试将下列属性关联到该请求上：
* Username： 用户名，一个表示终端用户的字符串。通常的形式比如：kube-admin或者jane@example.com。
* UID： 终端用户的ID，比如Username更具有唯一性。
* Groups：用户所属的groups列表。
* Extra： 用户的其他信息，授权系统可以用来做一些额外的参考。

对于**认证**组件来说，以上这些值都是透明的，不进行解释。
这些值对后面的**授权**组件来说才是有意义的。

Kubernetes以同时开启**多种认证策略**，至少包括如下两种：
* service account tokens for service accounts。
* one method for normal user。

如果同时启用了多个**认证**组件，第一个成功认证的组件将会阻止后面的组件继续认证。
**API Server无法保证多个认证组件的执行顺序**。

对**认证通过的user**，都会在user所属的groups列表中增加group **system:authenticated**。

### X509 Client Certs
也即是Client Certificate 认证方式。

启动API Server时，通过加入`--client-ca-file=SOMEFILE`可以开启Client certificate认证。
`SOMEFILE`必须包含一个或者多个证书，用来认证提供给API Server的client。

如果一个client certificate被认证通过，`subject`的`common name`会被作为`username`附加到request上。从Kubernetes 1.4开始，client certificate的organization字段被用来作为user的group列表。

比如，使用`openssl`命令行工具生成一个证书请求：
```sh
openssl req -new -key jbeda.pem -out jbeda-csr.pem -subj "/CN=jbeda/O=app1/O=app2"
```
将会创建一个`CSR`，username时`jbeda`，并且属于2个group：`app1`和`app2`。

### Static Token File
当API Server启动时，指定`--token-auth-file=SOMEFILE`可以启用`static token file`方式进行认证。
API Server从`SOMEFILE`文件中获取`bearer token`。
Token file是一个csv文件，每一行至少包括3列：token,user name, user uid。第四列（可选的）时user group，如果user group有多个的话要加双引号。

``` csv
token,user,uid,"group1,group2,group3"
```

当前，bearer token的有效期是永久的。
修改token list需要重启API Server。

**Putting a Beareer Token in a Request**
当一个HTTP请求使用bearer token认证时，API Server期望存在请求头`Authorization Bearer THETOKEN`。

### Bootstrap Tokens
Kubernetes 1.9，this feature is currently in `alpha`。
### Static Password File
启动API Server时，指定`--basic-auth-file=SOMEFILE`就开启了`Static Password File`认证模式。
`SOMEFILE`也是一个csv文件，和static token file类似（第一列是password）。
```csv
password,user,uid,"group1,group2,group3"
```

当前，static password的basic auth credentials也是永久的。
修改password list也需要重启API Server。

当一个HTTP请求使用basic auth认证时，API Server期望存在请求头`Authorization Basic BASE64ENCODED(USER:PASSWORD)`。
### Service Account Tokens
一个Service Account是一个自动enabled的authenticator，它使用signed bearer tokens验证requests。

该plugin使用两个optional flags：
* **--service-account-key-file** PEM编码的key文件，用来签名bearer tokens，如果没有指定，将使用API Server的TLS private key。
* **--service-account-lookup** 如果enabled，API删除的tokens将被revoked。

Service accounts通常由API Server通过[Service Account Admission Controller](../serviceaccounts/admin-guide-to-sa.md)自动创建，并关联到pod里面。

Bearer tokens将自动mount到Pod中容器的指定位置，并且允许in-cluster processes与API Server交互。

Account也可以使用PodSpec.serviceAccountName显式的绑定到pods中。
```yaml
apiVersion: apps/v1 # this apiVersion is relevant as of Kubernetes 1.9
kind: Deployment
metadata:
  name: nginx-deployment
  namespace: default
spec:
  replicas: 3
  template:
    metadata:
    # ...
    spec:
      serviceAccountName: bob-the-bot
      containers:
      - name: nginx
        image: nginx:1.7.9
```

Service account bearer tokens非常适合在集群外部使用，适合于long standing jobs认证。
可以通过命令行`kubectl create serviceaccount (NAME)` 在当前namespace创建一个service account，并关联一个secret。

```sh
$ kubectl create serviceaccount jenkins
serviceaccount "jenkins" created
$ kubectl get serviceaccounts jenkins -o yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  # ...
secrets:
- name: jenkins-token-1yvwg
```

创建的secret包含API Server的public CA和一个签名的JSON Web Token(JWT)。
```
$ kubectl get secret jenkins-token-1yvwg -o yaml
apiVersion: v1
data:
  ca.crt: (APISERVER'S CA BASE64 ENCODED)
  namespace: ZGVmYXVsdA==
  token: (BEARER TOKEN BASE64 ENCODED)
kind: Secret
metadata:
  # ...
type: kubernetes.io/service-account-token
```
签名的JSON Web Token可以作为bearer token来认证当前的service account。

Service Account会被认证为：
* username：system:serviceaccount:(NAMESPACE):(SERVICEACCOUNT)
* group： system:serviceaccounts，system:serviceaccounts:(NAMESPACE)

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
## 匿名请求
如果允许匿名请求，所有没有被认证模块`拒绝`的请求，都被认为是匿名请求。
对于匿名请求：
* username: system:anonymous
* group: system.unauthenticated

举个例子，如果API Server提供了token authentication，并且允许匿名请求。
* 如果一个请求，带着一个invalid token，API Server将返回401 `unauthorized`。
* 如果一个请求，没有提供token，API Server将把它作为匿名请求。

## [User impersonation](impersonation.md)
