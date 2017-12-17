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

3. 可以查看是否特殊指定了storage driver
    * 查看/etc/docker/daemon.json
    * `ps auxw | grep dockerd`查看启动dockerd时是否添加了**--storage-driver**

## AUFS工作原理
AUFS是一个**union filesystem**：it layers multiple directories on a single Linux host and presents them as a single directory。
这些目录在AUFS的术语中称为branches，在Docker的术语中称为layers。The unification process is referred to a **union mount**。

![](pics/aufs_layers.jpg)

每一个镜像层和容器层，都是宿主机上**/var/lib/docker/**目录下的一个子目录。
The union mount provides the unified view of all layers。
AUFS uses the Copy-on-Write (CoW) strategy to maximize storage efficiency and minimize overhead

### Image Layers
关于镜像层和容器层的所有信息都在宿主机上**/var/lib/docker/aufs/**的子目录下：
* diff/: the contents of each layer, each stored in a separate subdirectory
* layers/: metadata about how image layers are stacked. This directory contains one file for each image or container layer on the Docker host. Each file contains the IDs of all the layers below it in the stack (its parents).
* mnt/: Mount points, one per image or container layer, which are used to assemble and mount the unified filesystem for a container. For images, which are read-only, these directories will always be empty.

### Container Layer
如果container在运行，the contents of /var/lib/docker/aufs/ change in the following ways:
* diff/: Differences introduced in the writable container layer, such as new or modified files.
* layers/: Metadata about the writable container layer’s parent layers.
* mnt/: A mount point for each running container’s unified filesystem, exactly as it appears from within the container.

## 容器如何读写
### 读
* **文件不存在于container layer**: 如果容器要打开一个在容器层中不存在的文件，storage driver从容器层下的第一个镜像层由上往下开始搜寻，从找到的第一个镜像层中读取文件。
* **文件只存在于container layer**: 直接从容器层读取文件。
* **文件既存在于container layer又存在于image layer**: 从容器层读取文件。容器层中的文件**隐藏**了同名的镜像层中的文件。

### 修改文件或者目录
* **Writing to a file for the first time**：**aufs driv·er**执行`copy_up`操作，将文件从某个镜像层拷贝到容器层，然后容器将变更写到容器层中的文件副本。 
* **Deleting files and directories**
    * 如果删除文件，容器层中会创建一个whiteout文件。位于镜像层中的文件不会被删除，镜像层是只读的。whiteout文件会让文件变的对容器不可用。
    * 如果删除目录，容器层中会创建一个opaque文件。同样opaque文件可以隐藏镜像中的指定目录。
* **Renaming directories**: Calling rename(2) for a directory is not fully supported on AUFS. It returns EXDEV (“cross-device link not permitted”), even when both of the source and the destination path are on a same AUFS layer, unless the directory has no children. Your application needs to be designed to handle EXDEV and fall back to a “copy and unlink” strategy.

## AUFS and Docker performance

