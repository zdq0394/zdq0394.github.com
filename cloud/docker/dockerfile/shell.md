# SHELL
``` sh
SHELL ["executable", "parameters"]
```

一些指令，比如RUN, CMD, ENTRYPOINT等有shell和exec两种执行方式。那么shell形式执行命令的具体shell是什么呢？当然是base image默认的shell。
默认的shell在Linux下面是**["/bin/sh", "-c"]**，在Windows下是**["cmd", "/S", "/C"]**。SHELL指令必须是JSON Array形式的。
如果不想使用base image默认的shell，可以通过**SHELL**指令设定。

SHELL指令可以出现多次。SHELL指令覆盖所有前面的SHELL指令，并影响随后的指令的shell执行形式。


