# EXPOSE
``` Dockerfile
EXPOSE <port> [<port>/<protocol>...]
```

**EXPOSE**指令告知Docker这个容器将监听在某个port，默认是TCP端口。

**EXPOSE**并不会实际发布这个端口，这个作用类似于镜像制作者和容器运行者之间的一个约定：需要发布某个端口。

运行时实际发布端口需要通过"-p"指定映射某个外部端口，或者通过"-P"标识发布所有容器端口。
