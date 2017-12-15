# Volumes
Volumes是对容器产生和使用的数据进行持久化的首选机制。
Bind mounts依赖于宿主机的文件目录；Volumes完全由docker管理。

![](pics/tom-volume.png)

与bind mounts相比，volumes有一下优势：
* Volumes更容易备份和迁移。
* 可以通过Docker CLI和Docker API管理volumes。
* Volumes既可以在Linux容器又可以在Windows容器中使用。
* Volumes可以更安全的在多个容器中共享。
* Volume drivers可以将数据存储在远端或者云端服务器，可以加密。
* 新的volume中的内容可以很容易被容器pre-populated。

Volumes使用`rprivate` bind 级联。对volumes来说，Bind propagation不能配置。

## -v还是--mount
Docker 17.06以前，`-v`或者`--volume`在独立的容器上使用，`--mount`在services上使用。
从17.06开始，`--mount`也可以在独立的容器上使用。

