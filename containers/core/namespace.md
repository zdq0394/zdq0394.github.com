# Linux Namespace
## Linux Namespace简介
Linux Namespace提供了一种内核级别**隔离系统资源**的方法，通过将系统的全局资源放在不同的namespace中，来实现**资源隔离**的目的。

不同namespace中的程序，可以享有一份独立的系统资源。

目前Linux中提供了`六类`系统资源的隔离，分别是：
* MNT: 隔离文件系统挂载点。
* UTS: 隔离主机名和域名信息。
* IPC: 隔离进程间通信。
* PID: 隔离进程的ID。
* Net: 隔离网络资源。
* User: 隔离用户和用户组的ID。
比较新的内核支持**Cgroup**这个namespace。

下面简单的介绍一下这些Namespace的使用和功能。
## Namespace的使用
涉及到Namespace的操作接口包括**clone()、setns()、unshare()**以及还有`/proc`下的部分文件。为了使用特定的Namespace，在使用这些接口的时候需要指定以下一个或多个参数：

* CLONE_NEWNS: 用于指定Mount Namespace。
* CLONE_NEWUTS: 用于指定UTS Namespace。
* CLONE_NEWIPC: 用于指定IPC Namespace。
* CLONE_NEWPID: 用于指定PID Namespace。
* CLONE_NEWNET: 用于指定Net Namespace。
* CLONE_NEWUSER: 用于指定User Namespace。

### clone系统调用
可以通过clone系统调用来创建一个独立Namespace的进程，它的函数描述如下：

```c
int clone(int (*child_func)(void *), void *child_stack, int flags, void *arg);  
```
它通过flags参数来控制创建进程时的特性，比如新创建的进程是否与父进程共享虚拟内存等。比如可以传入CLONE_NEWNS标志使得新创建的进程拥有独立的Mount Namespace，也可以传入多个flags使得新创建的进程拥有多种特性，比如：

```c
flags = CLONE_NEWNS | CLONE_NEWUTS | CLONE_NEWIPC;  
```
传入这个flags，新创建的进程将同时拥有独立的Mount Namespace、UTS Namespace和IPC Namespace。

### 通过/proc文件查看Namespace

从3.8内核开始，用户可以在`/proc/$pid/ns`下看到本进程所属的Namespace的文件信息。

```sh
# ls -la /proc/28634/ns
total 0
dr-x--x--x 2 root root 0 Sep 29 15:18 .
dr-xr-xr-x 9 root root 0 Sep 29 15:17 ..
lrwxrwxrwx 1 root root 0 Sep 29 15:19 cgroup -> cgroup:[4026531835]
lrwxrwxrwx 1 root root 0 Sep 29 15:19 ipc -> ipc:[4026531839]
lrwxrwxrwx 1 root root 0 Sep 29 15:19 mnt -> mnt:[4026531840]
lrwxrwxrwx 1 root root 0 Sep 29 15:19 net -> net:[4026531957]
lrwxrwxrwx 1 root root 0 Sep 29 15:19 pid -> pid:[4026531836]
lrwxrwxrwx 1 root root 0 Sep 29 15:19 user -> user:[4026531837]
lrwxrwxrwx 1 root root 0 Sep 29 15:19 uts -> uts:[4026531838]
```
其中4026531839表明是Namespace的ID，`如果两个进程的NamespaceID相同表明两个进程同处于一个命名空间中`。

**这里需要注意的是**：只要/proc/$pid/ns/对应的Namespace文件被打开，并且该文件描述符存在，即使该PID对应的进程被销毁，这个Namespace会依然存在。可以通过挂载的方式打开文件描述符：

``` c
touch ~/mnt  
mount --bind /proc/28634/ns/mnt ~/mnt 
``` 
这样就可以保留住PID为28634的进程的Mount Namespace了，即使28634进程被销毁或者退出，ID为4026531840的Mount Namespace依然会存在。


### setns用来加入已存在的Namepspace
setns()函数可以把进程加入到指定的Namespace中，它的函数描述如下：

``` c
int setns(int fd, int nstype);  
```
它的参数描述如下：

* fd参数：表示文件描述符，前面提到可以通过打开/proc/$pid/ns/$namespace的方式将指定的Namespace保留下来，也就是说可以通过文件描述符的方式来索引到某个Namespace。
* nstype参数：用来检查fd关联Namespace是否与nstype表明的Namespace一致，如果填0的话表示不进行该项检查。

### unshare创建新的Namespace
unshare()系统调用用于将当前进程和所在的Namespace分离，并加入到一个新的Namespace中，相对于setns()系统调用来说，unshare()不用关联之前存在的Namespace，只需要指定需要分离的Namespace就行，该系统调用会自动创建一个新的Namespace。

unshare()的函数描述如下：

```c
int unshare(int flags);  
```
其中flags用于指明要分离的资源类别，它支持的flags与clone系统调用支持的flags类似，这里简要的叙述一下几种标志：

* CLONE_FILES: 子进程一般会共享父进程的文件描述符，如果子进程不想共享父进程的文件描述符了，可以通过这个flag来取消共享。
* CLONE_FS: 使当前进程不再与其他进程共享文件系统信息。
* CLONE_SYSVSEM: 取消与其他进程共享SYS V信号量。
* CLONE_NEWIPC: 创建新的IPC Namespace，并将该进程加入进来。

与其它的namespace不同，unshare()和setns()系统调用对**PID namespace**时：
* 调用进程会为它的子进程分配一个新的PID Namespace，但是调用进程本身不会被移到新的Namespace中。
* 调用进程第一个创建的子进程在新Namespace中的PID为1，并成为新Namespace中的init进程。

setns()系统调用也是类似的，调用者进程并不会进入新的PID Namespace，而是随后创建的子进程会进入。

为什么创建其他的Namespace时unshare()和setns()会直接进入新的Namespace，而唯独PID Namespace不是如此呢？因为调用getpid()函数得到的PID是根据调用者所在的PID Namespace而决定返回哪个PID，进入新的PID namespace会导致PID产生变化。而对用户态的程序和库函数来说，他们都认为进程的PID是一个常量，PID的变化会引起这些进程奔溃。换句话说，一旦进程创建以后，那么它的PID namespace的关系就确定下来了，进程不会变更他们对应的PID namespace。

### 小结
通过上面简单的概述，对于Namespace的操作有以下方式：

1. 可以在进程刚创建的时候通过clone系统调用为新进程分配一个或多个新的Namespace。
2. 通过setns()将进程加入到已有的Namespace中。
3. 通过unshare()为已存在的进程创建一个或多个新的Namespace。
4. 可以通过`/proc/$PID/ns`来查看进程所属的Namespace。
## Mount Namespace
`Mount Namespace`用来隔离文件系统的挂载点，不同`Mount Namespace`的进程拥有不同的挂载点，同时也拥有了不同的文件系统视图。
`Mount Namespace`是历史上第一个支持的Namespace，它通过CLONE_NEWNS来标识的。

### 挂载的概念
挂载的过程是通过mount系统调用完成的，它有几个参数：一个是已存在的普通文件名，一个是可以直接访问的特殊文件，一个是特殊文件的名字。这个特殊文件一般用来关联一些存储卷，这个存储卷可以包含自己的目录层级和文件系统结构。

mount所达到的效果是：像访问一个普通的文件一样访问位于其他设备上文件系统的根目录，也就是将该设备上目录的根节点挂到了另外一个文件系统的叶节点上，达到了给这个文件系统扩充容量的目的。

可以通过`/proc/$PID/mountinfo`查看一个进程的挂载信息，具体做法如下：

``` sh
# cat /proc/29165/mountinfo
19 25 0:18 / /sys rw,nosuid,nodev,noexec,relatime shared:7 - sysfs sysfs rw
20 25 0:4 / /proc rw,nosuid,nodev,noexec,relatime shared:12 - proc proc rw
21 25 0:6 / /dev rw,nosuid,relatime shared:2 - devtmpfs udev rw,size=8196884k,nr_inodes=2049221,mode=755
22 21 0:14 / /dev/pts rw,nosuid,noexec,relatime shared:3 - devpts devpts rw,gid=5,mode=620,ptmxmode=000
```

| 36 | 35 | 98:0 | /mnt1 | /mnt2 | rw,noatime | master:1 | - | ext3 | /dev/root | rw,errors=continue |
| ----- | ----- | ----- | ----- | ----- | ----- | ----- | ----- | ----- | ----- | ----- |
| (1) | (2)	| (3) | (4) | (5) | (6) | (7) | (8) | (9)	| (10) | (11) |

各个选项的含义如下：

* (1) mount ID: 对于mount操作一个唯一的ID
* (2) parent ID: 父挂载的mount ID或者本身的mount ID(本身是挂载树的顶点)
* (3) major:minor: 文件系统所关联的设备的主次设备号
* (4) root: 文件系统的路径名，这个路径名是挂载点的根
* (5) mount point: 挂载点的文件路径名(相对于这个进程的根目录)
* (6) mount options: 挂载选项
* (7) optional fields: 可选项，格式 tag:value
* (8) separator: 分隔符，可选字段由这个单个字符标示结束的
* (9) filesystem type: 文件系统类型 type[.subtype]
* (10) mount source: 文件系统相关的信息，或者none
* (11) super options: 一些高级选项（文件系统超级块的选项）

### 挂载传播
**进程**在创建**Mount Namespace**时，会把当前的文件挂载信息复制给新的Mount Namespace，新的Namespace中的所有mount操作仅影响自身的文件系统。

随着引入**挂载传播**的特性，Mount Namespace变得并不是完全意义上的资源隔离，这种传播特性使得多Mount Namespace之间的挂载事件可以相互影响。

**挂载传播**定义了不同namespace中挂载对象的关系，系统利用这些关系来决定挂载对象中的挂载事件对其他namespace中挂载对象的影响。

* 共享关系(MS_SHARED)：一个挂载对象的挂载事件会跨Namespace共享到其他挂载对象。
* 从属关系(MS_SLAVE): 传播的方向是单向的，即只能从Master namespace传播到Slave namespace。
* 私有关系(MS_PRIVATE): 不同Namespace的挂载事件是互不影响的(默认选项)。
* 不可绑定关系(MS_UNBINDABLE): 一个不可绑定的私有挂载，与私有挂载类似，但是不能执行挂载操作。

其中给挂载点设置挂载特性的例子如下：
```
# mount --make-shared /mntS      # 将挂载点设置为共享关系属性
# mount --make-private /mntP     # 将挂载点设置为私有关系属性
# mount --make-slave /mntY       # 将挂载点设置为从属关系属性
# mount --make-unbindable /mntU  # 将挂载点设置为不可绑定属性
```

注意在设置slave关系属性时，在本命名空间下的这个挂载点是Slave，而父命名空间下这个挂载点是Master，挂载传播的方向只能由master传给slave。

### 绑定挂载
绑定挂载的引入使得mount的其中一个参数不一定要是一个特殊文件，也可以是该文件系统上的一个普通文件目录。Linux中绑定挂载的用法如下：

```
mount --bind /home/work /home/zdq  
mount -o bind /home/work /home/zdq  

```
其中/home/work是磁盘上的存在的一个目录，而不是一个文件设备(比如磁盘分区)。如果需要将Linux中两个文件目录链接起来，可以通过绑定挂载的方式，挂载后的效果类似于在两个文件目录上建立了硬链接。

## UTS Namespace
UTS Namespace提供了主机名和域名的隔离，也就是struct utsname里的nodename和domainname两个字段。
不同Namespace中可以拥有独立的主机名和域名。

那么为什么需要对主机名和域名进行隔离呢？因为主机名和域名可以用来代替IP地址，如果没有这一层隔离，同一主机上不同的容器的网络访问就可能出问题。

## IPC Namespace
IPC Namespace是对进程间通信的隔离，进程间通信常见的方法有信号量、消息队列和共享内存。
IPC Namespace主要针对的是SystemV IPC和Posix消息队列，这些IPC机制都会用到标识符，比如用标识符来区分不同的消息队列，IPC Namespace要达到的目标是相同的标识符在不同的Namepspace中代表不同的通信介质(比如信号量、消息队列和共享内存)。

## PID Namespace
PID Namespace对进程PID重新标号，即不同的Namespace下的进程可以有同一个PID。
内核为所有的PID Namespace维护了一个树状结构，最顶层的是系统初始化创建的，被称为Root Namespace，由它创建的新的PID Namespace成为它的Child namespace，原先的PID Namespace成为新创建的Parent Namespace，这种情况下不同的PID Namespace形成一个等级体系：

**父namespace可以看到子namespace中的进程，可以通过信号对子namespace的进程产生影响，反过来子namespace无法看到父namespace里面的进程。**

有一点需要注意的是，`在新创建的PID Namespace中通过ps命令仍有可能看到Parent Namespace中的进程`，这是因为ps命令是从/proc文件系统下读取进程的信息，如果只想看到本Namespace具有的进程信息，还需要重新挂载/proc文件系统：

```
mount -t proc proc /proc 
```

## Net Namespace
Net Namespace主要是用来提供关于网络资源的隔离，包括网络设备（网卡、网桥）、IPV4或IPV6协议栈、路由表、防火墙、端口等信息，不同Namespace种可以拥有独立的网络资源。

`一个物理网络设备最多只能存在一个Network Namespace中，如果该Namespace被销毁后，这个物理设备不会回到它的Parent Namespace，而是会回到Root Namespace中`。

如果需要打通不同Namespace的通信，可以通过创建veth pair虚拟网络设备对的形式。虚拟网络设备对：有两端，类似于管道，分别放置在不同的Namespace中，从一端传入的数据，可以从另一端读取。

在Linux中也可以通过命令行来创建一个Network Namespace，用法如下：

``` sh
# ip netns add netns-demo 

```
当使用ip命令创建这个Network Namespace时，它会在/var/run/netns下为这个命名空间创建一个绑定挂载，这可以保证即使没有进程运行在这个Namespace下面，但这个Namespace依然存在。也可以通过ip在指定的Namespace中执行命令，操作如下：

``` sh
ip netns exec netns-demo ping 127.0.0.1  
ip netns exec netns-demo ip link list  
```
这个命令是在netns-demo命名空间中发出ping的命令和查看网卡设备情况。

## User Namespace
User Namespace允许Namespace间可以映射用户和用户组ID，这意味着一个进程在Namespace里面的用户和用户组ID可以与Namespace外面的用户和用户组ID不同。值得一提的是，一个普通进程(Namespace外面的用户ID非0)在Namespace里面的用户和用户组ID可以为0，换句话说这个普通进程在Namespace里面可以拥有root特权的权限。

当创建一个User Namespace时，有以下几点值得提一下:

1. User Namespace的第一个进程被赋予一系列的权限，可以执行这个Namespace中的一些初始化的工作。
2. 由于Namespace里面和外面的用户和用户组ID可以不同，当一个进程在Namespace里面执行一些影响整个系统的操作时，会出发系统的权限检查。
3. 如果这个Namespace没有对用户ID或者组ID进行映射的话，那么getuid()和getgid()会默认返回/proc/sys/kernel/overflowuid和/proc/sys/kernel/overflowgid的值，一般为 65534。
4. 尽管在Namespace里面的进程被赋予了一系列的权限，但是在Parent Namespace里面是没有权限的。

通常情况下创建User Namespace后第一步是映射一下Namespae里面和外面的用户和用户组的ID，这一步是通过往/proc/$pid/uid_map和/proc/$pid/gid_map写入映射信息实现的。在这两个文件中，映射信息的格式如下：

``` sh
ID-inside-ns   ID-outside-ns   length 
```

其中ID-inside-ns和length决定了映射的范围，而ID_outside_ns则需要根据如下两种情况讨论：

* 如果打开uid_map/gid_map的进程和目标进程在同一个Namespace，则这里的ID-outside-ns应该为Parent Namespace中的一个uid/gid，这种情况常见于Child自己设置映射，比如在Child User Namespace的子进程主动往/proc/$pid/uid_map中写入自己的ID映射关系，这个$pid是子进程在Parent User Namespace中的ID。
* 如果打开uid_map/gid_map的进程和目标进程不在同一个Namespace，则这里的ID-outside-ns则为该进程所在User Namespace中的一个uid/gid，最常见的就是Parent为Child设置映射，比如在Parent User Namespace的进程往/proc/$pid/uid_map中写入子进程的映射信息，这个$pid是子进程在Parent User Namespace中的ID。

除了上述的格式要求之外，对于uid/gid的映射还有几点约束：

* 写入uid_map/gid_map的进程，必须对PID进程所属User Namespace拥有CAP_SETUID/CAP_SETGID权限。
* 写入uid_map/gid_map的进程，必须位于PID进程的Parent或者Child User Namespace。
* 满足如下条件之一: ① 写入的数据将写入进程在Parent Namespace中的有效uid/gid映射到Child Namespace。此条规则允许Child Namespace中的进程为自己设置uid/gid ② 进程在Parent Namespace拥有CAP_SETUID/CAP_SETGID权限，那么它将可以映射到Parent Namespace中的任一uid/gid。不过由于Child Namespace中新创建的进程是没有在Parent Namespace中的权限的，那么此条规则仅用于，位于具有相应权限的Parent Namespace中的进程，来映射同namespace内的任一IDs。

User Namespace除了隔离用户ID和用户组ID之外，还对每个Namespace进行了Capability的隔离和控制，可以通过添加和删除相应的Capability来控制新Namespace中进程所拥有的权限，比如为新的Namespace中增加CAP_CHOWN权限，那么在这个Namespace的进程拥有改变文件属主的权限。

## 参考文献
* https://www.kernel.org/doc/Documentation/filesystems/sharedsubtree.txt