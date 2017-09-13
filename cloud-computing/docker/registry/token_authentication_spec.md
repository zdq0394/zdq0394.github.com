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


