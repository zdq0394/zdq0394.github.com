# FROM
## FROM命令
FROM命令可以有如下形式：
``` Dockerfile
FROM <image> [AS <name>]

FROM <image>[:<tag>] [AS <name>]

FROM <image>[:<digest>] [AS <name>]

```
**FROM**会开启一个新的**build stage**。

一个有效的Dockerfile必须从一个**FROM指令**开始。

* 只有**ARG指令**可以放在**FROM指令**之前。
* FROM可以在Dockerfile中出现多次，每次都开启一个新的build stage。

## ARG和FROM交互
**FROM指令**支持ARG指令中指定的变量。
比如:
``` Dockerfile
ARG  CODE_VERSION=latest
FROM base:${CODE_VERSION}
CMD  /code/run-app

FROM extras:${CODE_VERSION}
CMD  /code/run-extras
```

FROM之前的**ARG指令**不属于任何build stage，所以它不能在FROM后面的指令中使用。
如果要使用的话，必须在build stage中用ARG指令指定一个未赋值的变量。

比如：
```Dockerfile
ARG VERSION=latest
FROM busybox:$VERSION
ARG VERSION
RUN echo $VERSION > image_version
```