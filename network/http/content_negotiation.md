# 内容协商与转码
## 内容协商技术
决定服务器选择哪个页面最适合客户端：
* 让客户端来选择，客户端驱动的协商
* 服务器自动判定，服务器端驱动的协商
* 中间代理选择，透明协商

## 客户端驱动的协商
对于服务器来说，收到客户端你请求时只是返回响应，在其中列出可选的页面，让客户端决定使用哪个。
## 服务器驱动的协商
服务器通过客户端发送的首部集来获得用户的使用偏好，决定最合适的页面。

* 检查内容协商首部集。Accept系列首部。
* 根据User-Agent首部

Accept首部和实体首部：
Accept： Content-Type
Accept-Language： Content-Language
Accept-Charset: Content-Type
Accept-Encoding: Content-Encoding
