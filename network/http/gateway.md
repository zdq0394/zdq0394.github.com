# 网管、隧道和中继
## 网关
Web网关一侧使用HTTP协议，在另一侧使用另一种协议。（使用同一种协议HTTP，则称为代理）。

* 协议网关
* 资源网关

## 隧道
Web隧道（tunnel）可以通过HTTP应用程序访问使用非HTTP协议的应用程序。

Web隧道允许用户通过HTTP连接发送非HTTP流量，这样就可以在HTTP上捎带其他协议数据了。使用Web隧道最常见的原因就是要在HTTP连接中嵌入非HTTP流量，这样，这类流量就可以穿过只允许Web流量通过的防火墙了。

### 建立HTTP隧道
Web隧道是用HTTP的CONNECT方法建立起来的。

CONNECT方法并不是HTTP/1.1核心规范的一部分，但却是一种得到广泛应用的扩展。

CONNECT方法请求**隧道网关**创建一条到达**任意目的服务器和端口**的TCP的连接，并对客户端和服务器之间的后继数据进行**盲转发**。

**CONNECT请求**
除了起始行之外，CONNECT语法和其他HTTP方法类似。

```http
CONNECT home.netscape.com:443 HTTP/1.0
User-agent: Mozilla/4.0
```

**CONNECT响应**
Connect响应不需要包含Content-Type首部。此时连接只是对原始字节进行转发，不再是报文的承载者，所以不再需要使用Content-Type了。
```
HTTP/1.0 200 Connection Established
Proxy-agent: Netscape-Proxy/1.1
```

### SSL隧道
最初开发Web隧道是为了通过防火墙来传输加密的SSL流量。

通常会用隧道将非HTTP流量穿过端口过滤防火墙。

为了降低对隧道的滥用，网关应该只为特定的知名端口，比如HTTPS的端口443打开隧道。
## 中继
HTTP中继（relay）是**没有完全**遵循HTTP规范的**简单HTTP代理**。
中继负责处理HTTP中建立连接的部分，然后对**字节**进行**盲转发**。

由于没有完全实现HTTP规范，盲转发非常容易导致互操作性问题，尤其是Keep-Alive持久连接问题。
