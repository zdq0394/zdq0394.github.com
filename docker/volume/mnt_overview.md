# Docker Storage：Manage data in Docker
Docker提供了三种方式将宿主机中的数据mount到容器中：
* volumes
* bind mounts
* tmpfs

无论选择哪种方式，从容器中看到的数据都是一样的，都是容器的文件系统中的一个文件或者目录。 

三种方式之间的不同之处是**数据在宿主机中位置不同**。

![](pics/types-of-mounts.png)

* Volumes： 存储在**宿主机文件系统**的一个目录下，在Linux上一般是（/var/lib/docker/volumes/），该目录只能被Docker管理。 非Docker进程不能改动这部分数据。 Volumes是持久化数据最好的方式。
* Bind mounts： 可以存储在**宿主机系统**的任何位置。可以是非常重要的系统文件。宿主机上的进程包括非Docker进程都能访问和改变。
* `tmpfs` mounts： 存储在宿主机的内存中，不会持久化到宿主机的文件系统中。

## Volumes
由Docker创建和管理。
可以直接通过`docker volume create`命令来创建一个volume，此时，volume就是Docker Host上的一个directory。当mount volume到容器的时候，在容器中的路径就是mount的路径。

一个volume可以同时mount到多个容器中。当没有容器使用volume的时候，volume仍然是可用的，不会自动删除。可以通过命令行`docker volume prune`删除所有不在使用中的volume。

Volume支持使用**volume drivers**，可以将数据保存在远程服务器上或者云端。

### Volume场景
* 在多个运行的容器中共享数据。多个容器可以同时mount一个volume，不论是read-write还是read-only。只有明确的remove，才会删除volumes。
* Docker宿主机上不确定存在特定的文件或者文件结构。Volume把容器的配置和宿主机的文件结构进行了解耦。
* 如果想把数据存储到远程服务器或者云端，而不是本地。
* 如果需要backup、恢复或者在不同的宿主机之间迁移数据。

## Bind mounts
Docker支持bind mounts比较早，与volume相比，bind mounts功能有限。
Bind mounts将宿主机上的一个文件夹或者文件mount到容器中。宿主机文件通过全路径引用。宿主机上不必事先存在这个文件或者文件夹，创建容器的时候会自动创建。 Bind mounts依赖宿主机上的特定的文件目录结构。
### Bind mounts使用场景
首先，应该尽可能的使用volumes。不过下列场景适合使用bind mounts：
* 容器共享宿主机的某些文件：比如，**/etc/resolv.conf**等。
* 宿主机和容器之间共享代码和构建包。
* 宿主机上有指定的目录结构，适合bind mounts。
## `tmpfs` mounts
`tmpfs` mount不会持久化到磁盘上。可以存储容器的敏感信息或者非持久化状态信息。

## Bind mounts和volumes注意点
挂载**empty volume**到容器的一个目录，容器目录中的文件会拷贝到volume中。

挂载**non-empty volume**或者`bind mounts`到容器的一个目录，则容器现有目录中的文件会被mount掉：所谓mount掉，是指容器中的文件并没有被删除，只是被隐藏了。当将volume或者`bind mounts` unmount之后，文件会恢复。