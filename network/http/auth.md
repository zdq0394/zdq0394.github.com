# HTTP认证
## 认证
认证就是要给出一些身份证明。
HTTP提供了一个原生的**质询/响应（challenge/response）**框架，简化了对用户的认证过程。

HTTP通过一组可定制的控制首部，为不同的认证协议提供了一个可扩展的框架。

* WWW-Authenticate，指定区域和认证协议
* Authorization，说明认证算法和身份凭证（用户名密码或者token）
* Authentication-Info, 如果授权证书时正确的，服务器就会将文档返回。有些授权算法会在可选的Authentication-Info首部返回一些与授权会话相关的附加信息。

认证协议也是在HTTP认证首部中指定的。
HTTP定义了两个官方的认证协议：基本认证和摘要认证。

## 安全域
Web服务器会将受保护的文档阻止成一个安全域（security realm）。每个安全域都可以有不同的授权用户集。
在HTTP质询首部WWW-Authenticate中包含安全域realm="Some Realm"。

## 基本认证
基本认证就是最流行的HTTP认证协议。也就是最常用的**用户名/密码**认证。

### 基本认证过程
* 客户端请求一个受保护的资源，资源属于dev域realm
* 服务器返回401 Auhtorization Required响应。响应首部包含认证质询**WWW-Authenticate: Basic realm="dev"**
* 客户端将用户名和密码用**冒号：**连接起来，并用Base-64编码
* 客户端重新发送请求，请求包含首部**Authorization Basic Base-64-encoded-username-and-password**

Base-64-encoded-username-and-password 将（由冒号分隔的）用户名和密码打包在一起，并用Base-64编码方式对其进行编码。

### 基本认证的安全缺陷
基本认证便捷灵活，但是极不安全。用户名和密码都是几乎以明文形式传播的，也没有采取任何措施防止对报文的篡改。

基本认证需要与SSL加密技术结合一起才能安全使用。

## 摘要认证
摘要认证是另一种HTTP认证协议。摘要认证并不是最安全的协议。摘要认证不能满足安全HTTP事务的很多需求。

摘要认证的遵循的箴言是：**绝不通过网络发送密码**。
客户端不会发送密码，而是发送一个“指纹”或密码的“摘要”，这是密码的不可逆扰码。

服务器端在发送WWW-Authenticate首部时，会发送一个随机数传送给客户端。客户端计算密码的摘要时，要加入随机数。

