# HTTP报文
## 报文流
* 以源服务器为中心，流向源服务器方向是流入（inbound）；流向客户端方向是流出（outbound）。
* 不管是请求报文还是响应报文，所有报文都会流向**下游（downstream）**。所有报文的发送者都在接收者的上游（upstream）。

## 报文的组成部分
* 请求报文：起始行（请求行）；（可选）首部字段；（可选）报文主体
* 响应报文：起始行（相应行）；（可选）首部字段；（可选）报文主体

### 请求报文
``` http request
<method> <request-URL> <version>
<headers>

<entity-body>
```
### 响应报文
``` http response
<version> <status-code> <reason-phrase>
<headers>

<entity-body>
```
## 起始行
### 方法
* GET
* HEAD
* PUT
* POST
* TRACE
* OPTIONS
* DELETE

### 请求URL
命名了所请求资源，或者URL路径组件的完整URL。
### 版本
```
HTTP/<major>.<minor>
```
### 状态码
* 信息状态码： 100-199
* 成功状态码： 200-299
* 重定向状态码： 300-399
* 客户端错误状态码： 400-499
* 服务器错误状态码： 500-599

### 原因短语
数字状态码的可读版本，只对人有意义。
响应行**HTTP/1.0 200 OK**和**HTTP/1.0 200 NOT OK**虽然原因短语含义不同，但是浏览器都当作成功处理。
## 首部字段
跟在起始行后面的就是零个、一个或者多个首部字段。
### 通用首部
* Connection
* Date
* MIME-Version
* Trailer
* Transfer-Encoding
* Update
* Via
* Cache-Control
* Pragma
### 请求首部
* Client-IP
* From
* Host
* Referer
* User-Agent
* Accept
* Accept-Charset
* Accept-Encoding
* Accept-Language
* TE
* Expect
* If-Match
* If-Modified-Since
* If-None-Match
* If-Range
* If-Unmodified-Since
* Range
* Authorization
* Cookie
* Max-Forward
### 响应首部
* Age
* Public
* Retry-After
* Server
* Title
* Warning
* Accept-Ranges
* Vary
* Set-Cookie
* WWW-Authenticate
### 实体首部
* Allow
* Location
* Content-Base
* Content-Type
* Content-Length
* Content-Encoding
* Content-Language
* Content-MD5
* Content-Location
* Content-Range
* ETag
* Expires
* Last-Modified
### 扩展首部
扩展首部时非标准的首部。
## 主体部分
HTTP报文的第三部分就是可选的实体主体部分。

HTTP报文可以承载很多类型的数字数据：图片、视频、HTML文档等。