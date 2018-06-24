# Gotty
## 概述
GoTTY是一个简单的基于Go语言的命令行工具，它可以将终端**TTY**作为web程序共享。
它会将命令行工具转换为web程序。

Gotty使用Chrome OS的终端仿真器**hterm**来在Web浏览器上执行基于JavaScript的终端。
重要的是，GoTTY运行了一个**Web套接字服务器**，它基本上是将TTY的输出传输给客户端，并从客户端接收输入（即允许客户端的输入），并将其转发给TTY。

## 安装部署
Gotty的安装和部署可以参见[Github Gotty](https://github.com/yudai/gotty)。
