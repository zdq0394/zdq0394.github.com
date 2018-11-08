# Docker Logging Driver
Docker包含多个logging机制，以便我们获取运行中的容器的信息。该机制被称为**logging driver**。

每个Docker Daemon都有一个默认的**logging driver**。
如果一个容器在启动的时候不明确指定，就会默认使用该**logging driver**。
## 配置docker daemon的logging driver
可以在daemon.json中设置logging driver。如果不设置，则默认使用"json-file"。
```json
{
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "10m",
        "max-file": "10",
        "labels": "my_test",
        "env": "os,customer"
    }
}

```
## 配置docker containers的logging driver
在启动容器时，可以设置不同于docker daemon的logging driver。
```sh
docker run -it --log-driver json-file --log-opt max-size=10m --log-opt max-file=10 alpine ash
```

## logging delivery mode
日志如何从容器发到logging driver呢？docker提供了两种方式。
* direct：默认方式，阻塞式。
* non-blocking：非阻塞式，每个容器都建立一个 ring buffer。
```sh
--log-opt mode=non-blocking --log-opt max-buffer-size=4m
```
