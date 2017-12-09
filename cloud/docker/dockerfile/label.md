# Label
## Label
```
LABEL <key>=<value> <key>=<value> <key>=<value> ...
```
**Label**指令为镜像添加**元数据**。Label是key-value对。

例子：
``` Dockerfile
LABEL "com.example.vendor"="ACME Incorporated"
LABEL com.example.label-with-value="foo"
LABEL version="1.0"
LABEL description="This text illustrates \
that label-values can span multiple lines."
```

通过一个LABEL命令指定多个kv对，避免镜像层次过多。
``` Dockerfile
LABEL multi.label1="value1" multi.label2="value2" other="value3"
```

``` Dockerfile
LABEL multi.label1="value1" \
      multi.label2="value2" \
      other="value3"
```

## MAINTAINER
``` Dockerfile
MAINTAINER <name>
```
该指令已经**废弃**。使用**LABEL**指令。
``` Dockerfile
LABEL maintainer="SvenDowideit@home.org.au"
```