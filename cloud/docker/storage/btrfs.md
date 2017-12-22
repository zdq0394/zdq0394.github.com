# btrfs storage driver
Btrfs是下一代**copy-on-write**文件系统。
它支持很多高级的存储技术，非常适合Docker。 
Btrfs已经进入内核。

Docker的**btrfs storage driver**利用了很多Btrfs的特性——**block-level operations**, **thin provisioning**, **copy-on-write snapshots**, 和**ease of administration**——进行镜像和容器的管理。
可以非常容易的将多个物理块设备合成一个Btrfs文件系统。
* Btrfs：文件系统
* btrfs：Docker storage driver

## Manager a Btrfs Volume
Btrfs的一个优点就是易于管理，不需要unmount文件系统，也不必重启Docker。
当空间变少的时候，Btrfs自动的扩展volumes，**in chunks of roughly 1 GB**。

增加一个块设备到volume：
* btrfs device add
* btrfs filesystem balance

```sh
$ sudo btrfs device add /dev/svdh /var/lib/docker
$ sudo btrfs filesystem balance /var/lib/docker
```

## How the btrfs storage driver works
**btrfs storage driver**和**devicemapper**以及其它的storage driver不同。
整个`/var/lib/docker/`目录都存储在Btrfs卷上，要求整个目录所处的文件系统都是Btrfs。

### Image and container layers on-disk


