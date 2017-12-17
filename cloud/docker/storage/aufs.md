# aufs Storage Driver
AUFS是**Union File System**。

## 配置AUFS
当启动Docker时，如果**AUFS driver**已经加载到内核，并且没有其它的storage driver，Docker会默认使用AUFS。
1. 使用下面的命令可以查看系统是否支持AUFS
```sh
$ grep aufs /proc/filesystems

nodev   aufs
```
2. 查看当前Docker的storage driver：
```sh
$ docker info

<truncated output>
Storage Driver: aufs
 Root Dir: /var/lib/docker/aufs
 Backing Filesystem: extfs
 Dirs: 0
 Dirperm1 Supported: true
<truncated output>
```