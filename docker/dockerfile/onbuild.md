# ONBUILD

``` Dockerfile
ONBUILD [INSTRUCTION]
```

**ONBUILD**指令在image中增加一个trigger指令，当这个image作为另外一个build的base image时执行。
Trigger指令将会在downstream build的上下文中执行，就好像在Downstream的Dockerfile中的FROM指令中立即插入了trigger指令。

任何build指令都可以注册为trigger指令，FROM和MAINTAINER指令除外。