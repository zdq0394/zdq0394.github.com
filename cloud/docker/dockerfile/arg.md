# ARG
``` Dockerfile
ARG <name>[=<default value>]
```
ARG定义的变量，可以在执行`docker build`时，通过参数`--build-arg`传入。

一个Dockerfile中可以定义一个或者多个ARG变量：
``` Dockerfile
FROM busybox
ARG user1
ARG buildno
```

## 默认值
ARG也可以定义变量的默认值：
``` Dockerfile
FROM busybox
ARG user1=someuser
ARG buildno=1
```

## 作用域
ARG从它定义的地方开始生效，到build stage结束为止，定义之前的引用皆为空值。
比如：
``` Dockerfile
1 FROM busybox
2 USER ${user:-some_user}
3 ARG user
4 USER $user
```
执行命令行：
``` sh
$ docker build --build-arg user=what_user .
```
第二行中user为空，所有生效的some_user。
第三行定义了ARG user，所以第四行中user的值为命令行传入的what_user。

ARG只在定义它的build stage生效。如果开始一个新的build stage，从另一个`FROM`开始，则需要重新定义ARG。

``` Dockerfile
FROM busybox
ARG SETTINGS
RUN ./run/setup $SETTINGS

FROM busybox
ARG SETTINGS
RUN ./run/other $SETTINGS
```

## ARG的使用
ARG和ENV都可以定义变量，然后在RUN指令中使用。ENV定义的变量比ARG拥有更高的优先级。

* ENV定义的变量会持久化到镜像中，可以通过docker inspecct查看；
* ARG定义的变量不会持久化到镜像中。

可以通过如下的方式改变上述行为：
```
1 FROM ubuntu
2 ARG CONT_IMG_VER
3 ENV CONT_IMG_VER ${CONT_IMG_VER:-v1.0.0}
4 RUN echo $CONT_IMG_VER
```

## 预定义的ARG
* HTTP_PROXY
* http_proxy
* HTTPS_PROXY
* https_proxy
* FTP_PROXY
* ftp_proxy
* NO_PROXY
* no_proxy

预定义的ARG默认**不会**通过docker histroy输出。

## Build Cache的影响
