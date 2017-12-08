# RUN
## RUN命令
RUN有两种形式：shell形式和exec形式。
* RUN commands： shell形式，默认Linux操作系统在**/bin/sh -c**中执行；windows系统在**cmd /S /C**中执行
* RUN ["executable","param1","param2"]： exec形式

## RUN说明
RUN指令将基于当前镜像在一个新的镜像层中执行commands，执行完毕会执行commit结果，产生一个新的镜像，然后新的镜像作为Dockerfile中下一条命令的基础层。

将RUN指令层次化符合Docker的核心原则：commits非常轻便，并且可以从image history中的任何点创建容器。

EXEC形式的RUN指令可以在不含shell中的base image中执行。

EXEC形式的RUN指令不会调用shell，所以也不会执行shell中的变量替换。如果一定要用，可以如下进行：
```Dockerfile
RUN ["sh", "-c", "echo $HOME"]
```

