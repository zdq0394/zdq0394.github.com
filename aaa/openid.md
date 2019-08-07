# OpenID 认证
## 术语
* 标识
* 用户代理
* 依赖方：relying party，RP。
* OpenID提供方：OpenID Provider Server，OP。
* OpenID提供方端点URL：接受OpenID认证协议消息的URL，它是通过对用户提供的标识执行自动发现时找到的。这个值必须是一个绝对的HTTP或HTTPS URL。
* OpenID提供方标识：
* User-Supplied标识：由用户出示给依赖方的标识，或者用户在OpenID提供方那里选择的标识。
* 声称的标识：用户声称自己拥有的标识；本协议的目标就是验证这个说法。声称的标识可以是下面的任意一个：
    * 如果它是一个URL，则是从用户提供的标识规格化儿来的标识。
    * 如果它是一个XRI，则是CanonicalID。
* OP-Local标识：为用户提供的一个候补标识，定位到某一个OpenID提供方，因此不一定是在用户控制下的。

## 协议概述
1. 用户通过他们的用户代理向依赖方提供一个User-Supplied标识初始化认证过程。
2. 在规格化了User-Supplied标识后，依赖方执行自动发现来确定用户使用的OpenID提供方终点URL。需要注意的是，User-Supplied标识也可以是一个OpenID提供方标识。
3. （可选的）依赖方和OpenID提供方建立一个`associatioin`——使用Diffie-Hellman Key Exchange密钥交换协议协商一个共享密钥。OpenID提供方使用association对消息签名，同时依赖方验证这些消息——`这样可以省略每次认证请求/响应后的后续验证签名的直接请求`。
4. 依赖方让用户的用户代理带着“认证请求”参数重定向到OpenID提供方。
5. OpenID提供方确定用户是否有权并愿意接受OpenID认证。
6. OpenID提供方让用户的用户代理重定向会依赖方，参数中指明是认证通过还是认证失败。
7. 依赖方校验从OpenID提供方接收到的信息，包括检查返回URL（Return URL），验证自动发现信息，检查nonce，并用在association阶段建立的共享密钥验证签名或者依赖方发送一个直接请求给OpenID提供方来进行验证。
