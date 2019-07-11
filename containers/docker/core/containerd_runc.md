# Containerd中一个容器的context分析
本文接着[容器及其layer存储分析](container_layout.md)继续分析containerd是如何管理一个容器的。

Docker daemon并不直接管理容器，管理镜像和容器是通过containerd来实现的；
containerd对容器runtime的管理是借助runc实现。

## containerd
进入`/var/run/docker/libcontainerd/containerd`可以发现如下目录：`4f0e4cc32ad2e846f0df0ca08df4be38b7a17876f66dfe055feab55ac527be3c`。
这个是前面启动的nginx容器的ID。
该文件夹中的state.json文件保存了容器的状态信息：
```json
{
    "bundle": "/var/run/docker/libcontainerd/4f0e4cc32ad2e846f0df0ca08df4be38b7a17876f66dfe055feab55ac527be3c",
    "labels": null,
    "noPivotRoot": false,
    "runtime": "/usr/libexec/docker/docker-runc-current",
    "runtimeArgs": [
        "--systemd-cgroup=true"
    ],
    "shim": "docker-containerd-shim",
    "stderr": "",
    "stdin": "",
    "stdout": ""
}
```
这里面有个属性`bundle`。熟悉OCI的同学对此不会陌生，这是OCI兼容的容器的context目录。

## bundle
什么是bundle？A `directory structure` that is written ahead of time, distributed, and used to seed the runtime for creating a container and launching a process within it.

进入bundle文件夹：
`/var/run/docker/libcontainerd/4f0e4cc32ad2e846f0df0ca08df4be38b7a17876f66dfe055feab55ac527be3c`
可以发现有3个标准输入输出的pipeline文件和一个json文件。

其中的config.json文件就是OCI规范指定的bundle中的容器配置文件。
该文件描述了启动容器所需要的几乎所有信息。
最关键的一部分是`root`属性，指定了要启动的容器的文件系统。

参考[runc](../../oci/runc.md)

不难发现，这正是上节提到的容器的layer的目录，其中merged是overlay2文件系统的挂载目录。
```json
    "root": {
        "path": "/var/lib/docker/overlay2/89dbd3a7893baa0efbf8f77ac58b3192561fd62891531eb73d68feb1e600af06/merged"
    }
```
