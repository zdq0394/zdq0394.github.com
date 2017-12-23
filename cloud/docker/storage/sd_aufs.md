# Storage Driver aufs
AUFS是一个**Union File System**。
Ubuntu以及Debian Stretch版本之前，`aufs`曾经是默认的storage driver。
Ubuntu 14.04下，通过`apt-get install -y docker.io`安装时会自动安装使用aufs。

## How the aufs storage driver works
AUFS是一个**union filesystem**：it layers multiple directories on a single Linux host and presents them as a single directory。
这些目录在AUFS文件系统中称为branches，在Docker中称为layers。
The unification process is referred to a **union mount**。

![](pics/aufs_layers.jpg)

每一个镜像层和容器层，都是宿主机上`/var/lib/docker/aufs`目录下的一个子目录。
The union mount provides the unified view of all layers。
AUFS uses the Copy-on-Write (CoW) strategy to maximize storage efficiency and minimize overhead。

### Image Layers
关于镜像层和容器层的所有信息都在宿主机目录`/var/lib/docker/aufs/`的子目录下：
* diff/: 每一层的具体内容，每一层都在一个单独的目录下。
* layers/: 关于`how image layers are stacked`的元数据。在该目录下，每个镜像层和容器层都对应一个文件，每个文件包含它依赖的所有层（all layers below it）的ID。
* mnt/: 每个镜像层或者容器层对应一个mount point，`used to assemble and mount the unified filesystem for a container`。**对images来说，由于所有的层都是read-only的，所以这些目录总是空的。**

### Container Layer
如果container在运行，the contents of `/var/lib/docker/aufs/` change in the following ways:
* diff/: Differences introduced in the writable container layer, such as new or modified files.
* layers/: Metadata about the writable container layer’s parent layers.
* mnt/: A mount point for each running container’s unified filesystem, exactly as it appears from within the container.

## How container reads and writes work with aufs
### Reading files
* **The file does not exist in the container layer**: 如果容器要打开一个在容器层中不存在的文件，storage driver从容器层下的第一个镜像层由上往下开始搜寻，从找到的第一个镜像层中读取文件。
* **The file only exists in the container layer**: 直接从容器层读取文件。
* **The file exists in both the container layer and the image layer**: 从容器层读取文件，并且容器层中的文件**隐藏**了镜像层中同名的文件。

### Modifying files or directories
* **Writing to a file for the first time**：**aufs driver**执行`copy_up`操作，将文件从某个镜像层拷贝到容器层，然后容器将变更写到容器层中的文件副本。 AUFS工作在file level，而不是block level，copy_up操作总是拷贝整个文件。
* **Deleting files and directories**
    * 如果删除文件，容器层中会创建一个`whiteout`文件。位于镜像层中的文件不会被删除，镜像层是只读的。`whiteout文件`会使镜像层中的文件对容器不再可用。
    * 如果删除目录，容器层中会创建一个`opaque`文件。同样`opaque文件`可以对容器隐藏镜像中的指定目录。
* **Renaming directories**: **Calling rename(2) for a directory is not fully supported on AUFS**。It returns EXDEV (“cross-device link not permitted”), even when both of the source and the destination path are on a same AUFS layer, unless the directory has no children。

## AUFS and Docker performance
To summarize some of the performance related aspects already mentioned：
* AUFS不如overlay2高效。不过对于PaaS等容器密度很高的场景是一个不错的选择。This is because AUFS efficiently shares images between multiple running containers, enabling fast container start times and minimal use of disk space.
* The underlying mechanics of how AUFS shares files between image layers and containers uses the page cache very efficiently.
* The AUFS storage driver can introduce significant latencies into container write performance. This is because the first time a container writes to any file, the file has to be located and copied into the containers top writable layer. These latencies increase and are compounded when these files exist below many image layers and the files themselves are large.

### Performance best practices
* Solid State Devices (SSD) provide faster reads and writes than spinning disks.
* Use volumes for write-heavy workloads: Volumes provide the best and most predictable performance for write-heavy workloads. This is because they bypass the storage driver and do not incur any of the potential overheads introduced by thin provisioning and copy-on-write. Volumes have other benefits, such as allowing you to share data among containers and persisting even when no running container is using them.
