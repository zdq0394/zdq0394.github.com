# 客户端识别与cookie机制
Web服务器可能会同时与数千个不同的客户端进行对话。
HTTP最初是一个**匿名**、**无状态**的请求/响应协议。
## HTTP首部

| 首部名称 | 首部类型 | 描述 |
| -------- |---------- | --------- |
| From | 请求 | 用户的E-mail地址 |
| User-Agent | 请求 | 用户的浏览器软件 |
| Referer | 请求 | 用户是从这个页面上依照链接跳转过来的 |
| Authorization | 请求 | 用户名和密码 |
| Client-IP | 扩展（请求） | 客户端的IP地址 |
| X-Forwarded-For | 扩展（请求） | 客户端的IP地址 |
| Cookie | 扩展（请求） | 服务器产生的ID标签 |

前3种首部From、User-Agent和Referer都不足以识别用户。(From牵涉泄露用户隐私E-mail，所以客户端大多不会携带该信息。)

## 客户端IP地址
客户端IP地址可以通过TCP连接的对端地址可以查找，当然如果HTTP首部(Client-IP或者X-Forwarded-For）存在，优先级更高。

## 用户登录
Web服务器可以要求用户通过凭证（用户名和密码或者token）进行认证。

HTTP中包含了内建的机制**WWW-Authenticate**和**Authorization**首部进行用户认证。

## 胖URL

## cookie
cookie是当前识别用户，实现持久会话的最好方式。
### cookie类型
cookie包括两种：会话cookie和持久cookie。它们之间唯一的区别**过期时间**。

* 会话cookie： 一种临时cookie，它记录了用户访问站点时的设置和偏好。用户退出浏览器时，会话cookie就删除了。
* 持久cookie： 生存时间长一些，存储在硬盘上。通常会用来维护某个用户会周期性访问的站点的配置文件或登录名。

如果设置了一个Discard参数，或者没有设置Expires或Max-Age参数来说明扩展的过期时间，这个cookie就是一个**会话cookie**。

### cookie如何工作的
cookie就像服务器给用户贴的一个标签贴纸。当用户访问一个Web站点时，这个Web站点就可以读取那个服务器贴在用户身上的所有标签贴纸。

HTTP首部

服务器给客户端响应首部:

```
Set-cookie: id="1234"; domain="www.test.com"
```

客户端发给服务器的请求首部：

```
Cookie: id="1234"
```



