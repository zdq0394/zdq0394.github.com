# Docker Storage Driver概述
理想情况下，几乎没有数据会直接写入容器的writable layer。都是通过Volumes等写入数据。
但是也存在一些情况下需要向容器的writable layer写入数据，这就用到了storage driver。

Docker使用一些列不同的storage driver来管理镜像和容器中的文件系统。
这些storage drvier和Docker Volumes不同。Docker volumes管理的storage可以在多个容器中共享。

有效的使用storage driver，需要
* 理解Docker如何构建和存储images。
* 容器如何使用images。
* introduction to the technologies that enable both images and container operations

## Images和layers
镜像是基于一系列的layers构建的。每一层都是Dockerfile中的一个指令。除了最后一层，每一层都是只读的。

比如：
```Dockerfile
FROM ubuntu:15.04
COPY . /app
RUN make /app
CMD python /app/app.py
```
该Dockerfile包含四个命令，每个命令创建一个layer。
* `FROM`：以ubuntu:15.04 image构建一个基础层。
* `COPY`：把Docker client当前文件夹下的内容拷贝到/app中。
* `RUN`： 通过`make`命令编译应用。
* `CMD`： 最后一层指出如何运行容器。

Each layer is only a set of differences from the layer before it。The layers are stacked on top of each other。

当创建一个容器时，就在当前镜像上面增加了一个可写的layer。这一层通常称为**container layer**。针对容器的所有更改：比如创建新的文件，修改文件，删除文件，都被写入这个薄薄的可写的**container layer**。

![](pics/container-layers.jpg)

**storage driver**处理层与层之间的交互。

## Container and layers
容器和镜像的最大不同就是**top writable layer**。容器的所有写入（增加和修改已经存在的文件）都保存在**writable layer**。当容器删除后，**writable layer**也随之删除。底层的镜像保持不变。

每个容器都拥有自己的**writable container layer**，并且所有的改变都保存在**container layer**，多个容器可以共享同一个底层的镜像，并各自拥有自己的状态。

![](pics/containers-image.png)

Docker使用各种各样的storage driver来管理镜像层和可写层的内容。每个**storage driver**的实现不同，但是使用**stackable image layers**和**copy-on-write (CoW) strategy**。

## Container size on disk
查看运行的容器的size，可以通过命令行`docker ps -s`。
* size：每个容器的writable layer的size。
* virtual size: writable layer和read-only的镜像层的size之和。多个容器或许共享一些或者全部的read-only的image data。 

## The copy-on-write (CoW) strategy
Copy-on-write是一种共享和复制策略，为了效率最大化。如果一个文件或者目录在镜像的低层存在，另一个层要访问这个文件，该层只是利用底层存在的这个文件，当要修改这个文件时，才把这个文件从低层拷贝到当前层。如此可以最小化I/O操作，并且使每层都保持一个很小的size。
### Sharing promotes smaller images
共享产生更小的镜像。