# Docker Registry v2 Authentication
Docker Registry v2 Authentication 流程如下：
![](pics/v2_registry_auth.png)

1. 准备往registry进行push/pull操作。
2. 如果registry需要authorization，将会返回一个401 Unauthorized HTTP的响应，并且响应中包含如何认证的信息。
3. Registry client向authorization service发起认证的请求，请求一个Bearer token。
4. Authorization service返回一个对用户透明的Bearer token，代表用户的授权。
5. Registry client重试请求，本次请求在请求头中带有Bearer token。
6. Registry验证Bearer token and the claim set，然后授权client，开始push/pull。

## Requirements
* Registry clients：能够理解并响应resource server返回的认证要求。
* Authorization server：能够管理资源服务器托管的资源的权限控制(比如Docker Registry中的Repository)。
* Docker Registry：信任authorization server签发的tokens，并且能够验证token的合法性。

## Authorization Server Endpoint Descriptions
Authorization Server提供对Resource Provider的访问控制功能。
Reource Provider使用Authorization Server提供的认证和授权功能。

官方的Docker Registry使用Authorization Server来认证客户端并验证对image repositories的授权。

## How to authenticate
Registry V1 clients会首先联系index，来发起push或者pull请求。在Registry V2的工作流中，clients应该首先向registry发起请求。如果registry server需要认证，将会返回401 Unauthorized响应，响应头中包含WWW-Authenticate header，指出如何认证。

例如，我(username jlhawn)试图往registry上传（push）一个镜像repo：samalba/my-app。由于registry需要认证，我会收到如下响应：

```HTTP
HTTP/1.1 401 Unauthorized
Content-Type: application/json; charset=utf-8
Docker-Distribution-Api-Version: registry/2.0
Www-Authenticate: Bearer realm="https://auth.docker.io/token",service="registry.docker.io",scope="repository:samalba/my-app:pull,push"
Date: Thu, 10 Sep 2015 19:32:31 GMT
Content-Length: 235
Strict-Transport-Security: max-age=31536000

{"errors":[{"code":"UNAUTHORIZED","message":"access to the requested resource is not authorized","detail":[{"Type":"repository","Name":"samalba/my-app","Action":"pull"},{"Type":"repository","Name":"samalba/my-app","Action":"push"}]}]}
```

HTTP Response Header指明了认证请求：

```HTTP
Www-Authenticate: Bearer realm="https://auth.docker.io/token",service="registry.docker.io",scope="repository:samalba/my-app:pull,push"

```

这个请求指出：the registry需要指定的认证服务器auth.docker.io签发的token。客户端（client）需要往https://auth.docker.io/token发请求：包含service和scope。

## Requesting a Token
定义从token endpoint获取bearer和refresh token的过程
### QUERY PARAMETERS

**service**

Resource Porvide，资源服务器，保存有需要保护的资源。

**offline_token**

是否和bearer token一起返回一个refresh token。
Refresh token允许进一步获取针对同一个主体的不同scope的bearer tokens。Refresh token没有过期时间，对客户端完全透明。

**client_id**

代表client的字符串。该client_id不需要注册到认证服务器。

**scope**

请求的资源

### TOKEN RESPONSE FIELDS

**token**

一个不透明的Bearer token，clients应该在随后的请求中将该token放在Authorization头中。

**access_token**

为了兼容OAuth 2.0。如果两个都出现，必须一致。

**expires_in**

（可选）持续时间（有效时间），以秒为单位，从token签发时间开始。默认时60s。

**issued_at**
（可选）符合RFC3339-serialized UTC时间标准的签发时间。 

**refresh_token**
（可选）需要妥善保存，仅当需要获取bearer token时，发往authorization server。

## Using the Bearer token

当client拿到bearer token之后，可以将token放在请求头中，再次向registry发送请求：

``` http
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJFUzI1NiIsImtpZCI6IkJWM0Q6MkFWWjpVQjVaOktJQVA6SU5QTDo1RU42Ok40SjQ6Nk1XTzpEUktFOkJWUUs6M0ZKTDpQT1RMIn0.eyJpc3MiOiJhdXRoLmRvY2tlci5jb20iLCJzdWIiOiJCQ0NZOk9VNlo6UUVKNTpXTjJDOjJBVkM6WTdZRDpBM0xZOjQ1VVc6NE9HRDpLQUxMOkNOSjU6NUlVTCIsImF1ZCI6InJlZ2lzdHJ5LmRvY2tlci5jb20iLCJleHAiOjE0MTUzODczMTUsIm5iZiI6MTQxNTM4NzAxNSwiaWF0IjoxNDE1Mzg3MDE1LCJqdGkiOiJ0WUpDTzFjNmNueXk3a0FuMGM3cktQZ2JWMUgxYkZ3cyIsInNjb3BlIjoiamxoYXduOnJlcG9zaXRvcnk6c2FtYWxiYS9teS1hcHA6cHVzaCxwdWxsIGpsaGF3bjpuYW1lc3BhY2U6c2FtYWxiYTpwdWxsIn0.Y3zZSwaZPqy4y9oRBVRImZyv3m_S9XDHF1tWwN7mL52C_IiA73SJkWVNsvNqpJIn5h7A2F8biv_S2ppQ1lgkbw
```