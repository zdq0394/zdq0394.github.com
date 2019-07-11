# Bind Mounts的使用
Docker很早就开始支持`bind mounts`。
与`volumes`相比，`bind mounts`功能有限。
使用`bind mount`，宿主机上的一个文件或者目录被mount到虚拟机中。宿主机上的文件或者目录通过的绝对路径引用。而使用`volumes`的话，Docker会在宿主机上的**Docker storage directory**（在linux上，/var/lib/docker/volumes）中创建一个新的目录，并且由Docker来管理这个空间。

Mount目录或者文件时，文件或者目录不必在宿主机上存在，但是父目录需要存在。

![](pics/tom-bind.png)

## -v还是--mount
Docker 17.06以前，`-v`或者`--volume`在独立的容器上使用，`--mount`在services上使用。
从17.06开始，`--mount`也可以在独立的容器上使用。

### -v或者--volume
包含三部分，冒号（`:`）分隔。
* 宿主机上的文件或者目录路径。
* 挂在到容器中的路径（文件或者目录路径）。
* 可选的，volume的权限。可以由多个权限，由逗号分隔：ro, consistent, delegated, cached, z, and Z

### --mount
包含多个key-value对，由逗号分隔。
* type：mount类型（bind，volume或者tmpfs），这里是bind。
* source： 或者src，宿主机上的文件或者目录路径。
* destination：或者dst/target，容器中的挂载点。
* readonly
* bind-propagation：rprivate, private, rshared, shared, rslave, slave

### Differences Between -v/--volume and --mount
如果在宿主机不存在对应的目录或者文件：
* -v or --volume：自动创建**目录**。
* --mount：不会创建，生产一个error。

## Bind Propagation
**Bind propagation** defaults to `rprivate` for both **bind mounts** and **volumes**。
只有在**Linux宿主机**上，也只有**`bind mounts`**才能设置propagation。