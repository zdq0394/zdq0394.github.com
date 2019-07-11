# runc
Runc实现了OCI runtime-spec定义的container生命周期的管理功能。
官方的说法是：`runc is a CLI tool for spawning and running containers according to the OCI specification.`

Runc的实现紧跟[runtime-spec](https://github.com/opencontainers/runtime-spec)。

## runc的实践
runc的实践可以参考[官方文档](https://github.com/opencontainers/runc)。

### 创建一个OCI Bundle
创建一个OCI Bundle分两步：
1. 创建容器的rootfs
2. 创建该容器对应的config.json

1、容器的rootfs可以使用docker命令将某个容器的filesystem导出
```sh
# create the top most bundle directory
mkdir /mycontainer
cd /mycontainer

# create the rootfs directory
mkdir rootfs

# export busybox via Docker into the rootfs directory
docker export $(docker create busybox) | tar -C rootfs -xvf -
```

2、config.json文件可以使用`runc spec`命令生成一个模板，然后进行必要的更改。

此时，得到了如下的文件：
```sh
[root@localhost mycontainer]# ls
config.json  rootfs
```
这是个一个典型的OCI Bundle文件结构。

### 运行OCI Bundle
打开config.json，可以发现root目录指向当前文件夹下的rootfs。这也是典型的配置。

典型配置下的测试就不做了，我们把rootfs移出去，测试一下。
```sh
# mv rootfs /tmp/
# ls
config.json

```
然后修改config.json修改root.path
```json
        "root": {
                "path": "/tmp/rootfs",
                "readonly": true
        },
```

执行runc命令，创建容器并启动
```sh
[root@localhost mycontainer]# runc create rootfs-out
[root@localhost mycontainer]# runc list
ID           PID         STATUS      BUNDLE                                   CREATED                          OWNER
rootfs-out   29220       created     /home/runc-bundle-examples/mycontainer   2018-11-11T01:49:54.964615607Z   root
[root@localhost mycontainer]# runc start rootfs-out
[root@localhost mycontainer]# runc list
ID           PID         STATUS      BUNDLE                                   CREATED                          OWNER
rootfs-out   29220       running     /home/runc-bundle-examples/mycontainer   2018-11-11T01:49:54.964615607Z   root
[root@localhost mycontainer]# runc list
ID           PID         STATUS      BUNDLE                                   CREATED                          OWNER
rootfs-out   0           stopped     /home/runc-bundle-examples/mycontainer   2018-11-11T01:49:54.964615607Z   root
[root@localhost mycontainer]# runc delete rootfs-out
[root@localhost mycontainer]# runc list
ID          PID         STATUS      BUNDLE      CREATED     OWNER
```

这说明rootfs文件与config.json文件不必在同一个目录下。



