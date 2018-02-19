# Volume
``` Dockerfile
VOLUME ["/data"]
```
**VOLUME**指令将创建一个mount point，可以用来挂在宿主机或者其它容器的volume。

VOLUME指令的值有两种形式：
* JSON Array：VOLUME ["/var/log/"]
* Plain string： VOLUME /var/log /var/db

命令**docker run**会初始化新创建的volume，并将base image中的volume及其中的内容同步过来。
比如：
```
FROM ubuntu
RUN mkdir /myvol
RUN echo "hello world" > /myvol/greeting
VOLUME /myvol
```

这个Dockerfile构建的image，在执行**docker run**的时候会在/myvol创建一个挂载点，并把其中的greeting文件复制到新创建的volume中。

## 注意事项
* 基于Windows的容器，volume的目的地址，也就是容器中的挂载点必须是一个**空文件夹或者不存在的文件夹**并且**不能是C:盘**。
* 在VOLUME指令之后，改变volume的内容是无效的。