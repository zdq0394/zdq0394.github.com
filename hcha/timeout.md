# 超时于重试机制
## Nginx超时与重试
### 客户端超时设置
* client_header_timeout time： 指令指定了读取客户端请求头超时时间，默认60s。
* client_body_timeout time： 指令指定了读取客户端内容请求体超时时间，默认60s。这里的超时是指一个请求实体没有进入读取步骤，如果连接超过这个时间而客户端没有任何响应。
* send_timeout time： 指令指定了发送给客户端应答后的超时时间，Timeout是指没有进入完整established状态，只完成了两次握手，如果超过这个时间客户端没有任何响应，nginx将关闭连接。
* keepalive_timeout time [header_timeout]：参数的第一个值指定了客户端与服务器长连接的超时时间，超过这个时间，服务器将关闭连接。参数的第二个值（可选）指定了应答头中Keep-Alive: timeout=time的time值，这个值可以使一些浏览器知道什么时候关闭连接，以便服务器不用重复关闭，如果不指定这个参数，nginx不会在应答头中发送Keep-Alive信息。（但这并不是指怎样将一个连接“Keep-Alive”）。参数的这两个值可以不相同。
下面列出了一些服务器如何处理包含Keep-Alive的应答头：
    * MSIE和Opera将Keep-Alive: timeout=N头忽略。 
    * MSIE保持一个连接大约60-65秒，然后发送一个TCP RST。 
    * Opera将一直保持一个连接处于活动状态。 
    * Mozilla将一个连接在N的基础上增加大约1-10秒。 
    * Konqueror保持一个连接大约N秒。 

### DNS解析超时设置
resolver_timeout 30s

### 代理超时设置
* proxy_connect_timeout： 和后端服务器建立连接的超时时间，不超过75s。
* proxy_read_timeout： Defines a timeout for reading a response from the proxied server. The timeout is set only between two successive read operations, not for the transmission of the whole response. If the proxied server does not transmit anything within this time, the connection is closed.
* proxy_send_timeout： Sets a timeout for transmitting a request to the proxied server. The timeout is set only between two successive write operations, not for the transmission of the whole request. If the proxied server does not receive anything within this time, the connection is closed.
