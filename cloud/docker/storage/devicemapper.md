# devicemapper
## Device Mapper简介
[Device Mapper](../../../linux/devicemapper.md)是Linux系统中基于内核的**高级卷管理技术框架**。
它是内核中支持逻辑卷管理的**通用设备映射机制**，为实现**块设备驱动**提供了一个高度模块化的内核架构，包含三个重要的对象概念：Mapped Device、Mapping Table、Target device。
Docker的**devicemapper**存储驱动基于该框架的**thin-provisioning**和**snapshotting**功能来实现对镜像和容器的管理。

* Device Mapper： Linux Kernel Framework
* devicemapper： Docker Storage Driver

Docker Engine的**devicemapper存储驱动**使用专用**块设备**来存储数据而非文件系统。块设备可以通过增加物理磁盘扩展，比通过操作系统在文件层面性能更好。


## How the `devicemapper` storage driver works
```sh
$ sudo lsblk

NAME                    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
xvda                    202:0    0    8G  0 disk
└─xvda1                 202:1    0    8G  0 part /
xvdf                    202:80   0  100G  0 disk
├─docker-thinpool_tmeta 253:0    0 1020M  0 lvm
│ └─docker-thinpool     253:2    0   95G  0 lvm
└─docker-thinpool_tdata 253:1    0   95G  0 lvm
  └─docker-thinpool     253:2    0   95G  0 lvm
```
当使用devicemapper时，Docker把镜像和层的内容存储在thinpool中，然后mount到`/var/lib/docker/devicemapper`下的子目录上，以此把数据暴露给容器。

### Image and Container Layers on-disk
`/var/lib/docker/devicemapper/metadata`目录包含关于Devicemapper配置本身和每个镜像和容器层的元数据。
`devicemapper`驱动使用snapshots，元数据信息包含snapshots。文件是JSON格式的。

`/var/lib/docker/devicemapper/mnt`目录包含每个镜像和容器层的mount point。镜像layer的mount points是空的，容器的mount point显示容器本身的文件系统，和从容器内部看是一样的。

### Image layering and sharing
`devicemapper`使用block devices，而不是filesystems，它在块而不是文件这个层次操作。

### SNAPSHOTS
`devicemapper`的另一重要特性是snapshots，有时也成为thin devices或者virtual devices；它仅仅存放每层之间的差异，非常轻量。

### devicemapper workflow
当以`devicemapper`作为存储驱动时，关于镜像和容器的所有对象都存放在目录`/var/lib/docker/devicemapper`中，which is backed by one or more block-level devices, either loopback devices (testing only) or physical disks。

* `base device`是lowest-level对象。这是thin poll本身。它包含一个文件系统。`base device`是每个镜像和容器层的起点。`base device` is a Device Mapper implementation detail, rather than a Docker layer.
* 关于`base device`和每个镜像／容器层的元数据以JSON格式存储在目录 /var/lib/docker/devicemapper/metadata/中。这些层都是copy-on-write snapshots。
* 每个容器的writable layer都被挂载到/var/lib/docker/devicemapper/mnt/下的一个mount point上。每个镜像层和不在运行的容器层都有一个空的目录。

每个镜像层都是它下面的镜像层的一个snapshot。镜像的最底层是`base device`的一个snapshot。运行一个容器，容器是对应的镜像的一个snapshot。

![](pics/two_dm_container.jpg)

## How container reads and writes work with `devicemapper`
### Reading files
使用`devicemapper`，读操作at the block level。

![](dm_container.jpg)

容器中的应用发起了对块`0x44f`的读请求。由于container只不过是镜像的一个thin snapshot，所以它没有这个block，却有一个指针指向这个块——包含该块的最近的镜像层。容器从这里读取该块到容器的内存中。

### Writting files
**Writing a new file**：往容器的中写数据由`allocate-on-demand`操作完成。文件的每个块都在容器的writable layer中分配，并将数据写入这些块。

**Updating an existing file**：只要相关的文件块才会拷贝到容器层，并不是所有的文件块。

**Deleting a file or directory**：当一个文件被删除后，`devicemapper`截获随后的读请求并返回**文件不存在**。

**Writing and then deleting a file**：If a container writes to a file and later deletes the file, all of those operations happen in the container’s writable layer. In that case, if you are using direct-lvm, the blocks are freed. If you use loop-lvm, the blocks may not be freed. This is another reason not to use loop-lvm in production.