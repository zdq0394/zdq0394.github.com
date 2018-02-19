# VFS Storage Driver
VFS storage driver不是一个Union Filesystem。
每一层都是磁盘上的一个文件夹，也没有**Copy-on-Write**的特性。
创建一个layer，是对前一个layer的**deep copy**。
与其它的storage driver相比，这会导致较差的性能和较多的磁盘占用。
然而，这种方式很稳定，并且在各种环境中都可用。

## Configure Docker with the vfs storage driver
1. 停止docker
2. 修改/etc/docker/daemon.json
``` json
{
  "storage-driver": "vfs"
}
```
3. 启动docker
4. 查看 `docker info`

Docker将创建/var/lib/docker/vfs/目录，包含docker用到的所有层。

## vfs Storage driver工作原理
VFS不是一个**union filesystem**。每个镜像层和容器层都是一个宿主机上/var/lib/docker/的一个子目录。The directory names do not directly correspond to the IDs of the layers themselves。

VFS不支持copy-on-write (COW)，所以每次创建一个新的layer，都是对其父layer的一个deep copy，每一层都会占用大量的磁盘空间。