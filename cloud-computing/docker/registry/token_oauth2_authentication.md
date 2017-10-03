OAuth2 Token Authentication

## Docker Registry v2 authentication using OAuth2

本文描述了在authorization server中对OAuth2协议的支持。 文档**RFC6749**可以作为本文描述的**协议**和**HTTP endpoints**的参考。

注意：并非所有token servers都实现了oauth2。如果使用HTTP POST方法请求endpoint返回404，可以查看Token文档以使用HTTP GET请求，所有的token servers都应该实现HTTP GET方法。

## Refresh token的格式
对客户端来说，**refresh token**的格式是完全透明（opaque）的。**refresh token**的格式由authorization server决定。The authorization should ensure the token is sufficiently long and is responsible for storing any information about long-lived tokens which may be needed for revoking。

**Token**中包含的任何信息都不应该被客户端提取和展示。

## Getting a token

``` http
POST /token
```
**请求头**

Content-Type: application/x-www-form-urlencoded

**请求参数**

***grant_type*** 
(REQUIRED) Type of grant used to get token：

* password：通过用户名和密码的方式获取token。如果要获取refresh token，需要设置grant type为**password**，并同时传递参数username和password。
* refresh_token：通过refresh token方式获取access token，需要同时传递参数refresh_token。

***service*** 

(REQUIRED) 资源服务的名字，服务保存有需要授权访问的资源。Refresh tokens will only be good for 获取访问服务的tokens。

***client_id*** 

(REQUIRED) 标识client的字符串。该client_id不一定要注册到authorization server，但是需要设置一个有意义的值，用来审计未注册的客户端。
[RFC6749 Appendix A.1](https://tools.ietf.org/html/rfc6749#appendix-A.1)定义了可以接受的语法。

***access_type*** 

(OPTIONAL) 请求访问的类型：

* offline：请求返回refresh token。
* online：默认值，返回short-lived access token。

如果grant type是refresh_token，仅返回一原来的旧refresh token。

***scope*** 

(OPTIONAL)请求的资源。各个资源由**空格**隔开。

例子：scope=repository:samalba/my-app:push。
如果请求的是refresh token，scopes可以时空的，因为refresh token不应该被scope限制。只有请求short-lived的access token时，需要有scope limitation。

***refresh_token*** 

(OPTIONAL) 当grant type是refresh_token时，该字段传递认证用的refresh token。

***username*** ***password***

(OPTIONAL) 当grant type是password时，这两个字段分别传递认证用的用户名和密码。

**响应字段**

***access_token*** 

(REQUIRED) An opaque **Bearer token**， 客户端在随后的请求头**Authorization**中要提供的token。这个token不应该被客户端解析或者解释，仅仅被当作一个字符串。

***scope***

(REQUIRED) access token中包含的授权的scope。该scope和请求的scope一致，或者是请求的scope的子集。

***expires_in***

(REQUIRED) token的有效期（秒数），从token颁发开始计算。默认60 seconds。 为了兼容旧的客户端，token的有效期不应小于60秒。

***issued_at***

(Optional) token的签发时间，RFC3339-serialized UTC standard time。
如果省略，默认从token交换完成开始。

***refresh_token***

(Optional) 当请求的access_type=offline时，返回的refresh token，以后用来获取针对同一subject的access tokens。客户端要安全保存该token，仅能发送给认证服务器。

## GETTING REFRESH TOKEN示例

``` http
POST /token HTTP/1.1
Host: auth.docker.io
Content-Type: application/x-www-form-urlencoded

grant_type=password&username=johndoe&password=A3ddj3w&service=hub.docker.io&client_id=dockerengine&access_type=offline

HTTP/1.1 200 OK
Content-Type: application/json

{"refresh_token":"kas9Da81Dfa8","access_token":"eyJhbGciOiJFUzI1NiIsInR5","expires_in":900,"scope":""}
```

## REFRESHING AN ACCESS TOKEN示例
```
POST /token HTTP/1.1
Host: auth.docker.io
Content-Type: application/x-www-form-urlencoded

grant_type=refresh_token&refresh_token=kas9Da81Dfa8&service=registry-1.docker.io&client_id=dockerengine&scope=repository:samalba/my-app:pull,push

HTTP/1.1 200 OK
Content-Type: application/json

{"refresh_token":"kas9Da81Dfa8","access_token":"eyJhbGciOiJFUzI1NiIsInR5":"expires_in":900,"scope":"repository:samalba/my-app:pull,repository:samalba/my-app:push"}
```

