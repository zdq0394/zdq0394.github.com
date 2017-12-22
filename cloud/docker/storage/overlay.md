# OverlayFS Storage Driver
OverlayFS是一个现代的**联合文件系统**。和AUFS相似，但是比AUFS实现更简单、性能更快。
* OverlayFS：文件系统
* overlay/overlay2：Docker storage driver

## How the `overlay` driver works
OverlayFS layers **two directories** on a single Linux host and presents them as **a single directory**。这些目录被称为`layers`，unification process被成为`union mount`。
在OverlayFS中，lower directory称为`lowerdir`；upper directory称为`updir`；联合后的统一的视图称为`merged`。

下图展示了Docker的镜像和容器层是如何layer的。镜像layer是`lowerdir`；容器layer是`upperdir`。统一的view通过`merged`目录暴露出来，这也是container的mount point。

![](pics/overlay_constructs.jpg)

如果image layer和container layer包含同一个文件，那么container layers中的文件将隐藏image layer中的文件。

`overlay`只支持**two layers**。这就意味镜像的多个层不能简单的实现为OverlayFS文件系统的多个层。

创建一个容器时，`overlay`驱动将combines the directory representing the image’s top layer plus a new directory for the container。
The image’s top layer is the lowerdir in the overlay and is read-only。
The new directory for the container is the upperdir and is writable。

### Image and container layers on-disk
