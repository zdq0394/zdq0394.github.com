# 日志记录与使用情况跟踪
## 记录内容
HTTP日志通常会记录一下几个字段：
* HTTP端和服务器的HTTP版本
* 所请求资源的URL
* 响应的HTTP状态码
* 请求和响应的报文尺寸（包含所有的实体主体部分）
* 事务开始时的时间戳
* Referer首部和User-Agent首部

## 日志格式
### 常用日志格式
常用日志格式由NCSA定义。常用日志格式字段如下：
* remotehost： 请求端机器的主机名或IP地址
* username： 如果执行了ident查找，就是请求端已认证的用户名，一般都是**-**
* auth-username： 如果进行了认证，就是请求端已认证的的用户名。
* timestamp： 请求的日期和时间
* request-line： 精确的HTTP请求行文本
* response-code： 响应中返回的HTTP状态码
* response-size： 响应主体中的Content-Length，如果响应中没有返回主体，就记录为0。

### 组合日志格式
Apache服务器使用**组合日志格式**。组合日志格式比常用日志格式多了两个字段：**Referer**和**User-Agent**。

### Squid代理日志格式
Squid是一个古老的代理缓存。
Squid代理的日志格式如下：
* timestamp： 请求到达的时间戳，是从格林尼治标准时间1970年1月1日开始的秒数
* time-elapsed： 请求和响应通过代理传输所经历的时间（以毫秒为单位）
* host-ip： 客户端（请求端）主机的IP地址
* result-code/status： result字段是Squid类型的，说明在此请求过程中代理采取了什么动作；code字段是代理发送给客户端的HTTP响应码
* size： 代理响应客户端的字节长度，包括HTTP响应首部和主体
* method： 客户端请求的HTTP方法
* url： 客户端请求的URL
* rfc931-ident： 客户端经过认证的用户名
* hierarchy/from： hierarchy说明了代理向客户端发送请求时经由的路径；from字段说明了代理用来发起请求的服务器的名称
* content-type： 代理响应实体的Content-Type

## 命中率测量
命中率测量协议是对HTTP的一种扩展。命中率测量协议要求缓存**周期性**的向原始服务器汇报缓存访问的统计数据。

使用Meter首部。

