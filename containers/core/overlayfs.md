# OverlayFS
**Union Filesystem**是容器的核心技术之一。**OverlayFS**是联合文件系统（union filesystem）的一种。
然而，**OverlayFS**与其说是一种文件系统，不如说是一种mounting机制（It is more of a mounting mechanism than a file system）。

**OverlayFS**是一种**堆叠**文件系统，它依赖并建立在其它的文件系统之上（ext4/xfs等）。
**OverlayFS**并不直接参与磁盘空间结构的划分，仅仅是将来自底层文件系统中不同的目录进行**合并**，然后向用户呈现。
因此，用户见到的OverlayFS文件系统根目录下的内容就来自挂载时指定的不同目录的**合集**。

**OverlayFS**最基本的特性，简单的总结为以下3点：
* 上下层同名目录合并
* 上下层同名文件覆盖
* lower dir的文件写时拷贝
以上这三点对用户都是不被感知的。

## 挂载
挂载文件系统的基本命令如下：
```sh
mount -t overlay overlay -o lowerdir=lower1:lower2:lower3,upperdir=upper,workdir=work merged
```

其中：
* lowerdir，"lower1:lower2:lower3"表示不同的lower层目录，不同的目录使用":"分隔；层次关系依次为lower1 > lower2 > lower3（注：多lower层功能支持在Linux-4.0合入，Linux-3.18版本只能指定一个lower dir）
* upperdir，表示upper层目录
* workdir，文件系统挂载后用于存放临时和间接文件的工作基目录（work base dir）
* merged目录就是最终的挂载点目录

若一切顺利，在执行以上命令后，overlayfs就成功挂载到merged目录下了。

挂载选项支持（即"-o"参数）：
1）lowerdir=xxx：指定用户需要挂载的lower层目录（支持多lower，最大支持500层）
2）upperdir=xxx：指定用户需要挂载的upper层目录
3）workdir=xxx：指定文件系统的工作基础目录，挂载后内容会被清空，且在使用过程中其内容用户不可见
4）default_permissions：功能未使用
5）redirect_dir=on/off：开启或关闭redirect directory特性，开启后可支持merged目录和纯lower层目录
6）index=on/off：开启或关闭index特性，开启后可避免hardlink copyup broken问题

其中lowerdir、upperdir和workdir为基本的挂载选项。
`redirect_dir`和`index`涉及`overlayfs`为功能支持选项，除非内核编译时默认启动，否则默认情况下这两个选项不启用。

## 实践
文件目录`/mnt/mytest`包含一个xfs文件系统。
### mount之前
```sh
[root@docker mytest]# pwd
/mnt/mytest
[root@docker mytest]# ls
lower1  lower2  lower3  merged  upper  work
[root@docker mytest]# tree
.
├── lower1
│   ├── hello_dir
│   │   ├── hello.1.txt
│   │   └── hello.txt
│   └── lower1.txt
├── lower2
│   ├── hello_dir
│   │   ├── hello.2.txt
│   │   └── hello.txt
│   └── lower2.txt
├── lower3
│   ├── hello_dir
│   │   ├── hello.3.txt
│   │   └── hello.txt
│   └── lower3.txt
├── merged
├── upper
└── work
    └── work

10 directories, 9 files
```
### mount之后
```sh
[root@docker mytest]# mount -t overlay overlay -o lowerdir=lower1:lower2:lower3,upperdir=upper,workdir=work merged
[root@docker mytest]# df -h | grep "mytest/merged"
overlay         395G   33M  395G   1% /mnt/mytest/merged
```

### 查看merged文件夹目录内容
```sh
[root@docker mytest]# cd merged/
[root@docker merged]# ll
total 12
drwxr-xr-x 1 root root 42 Oct 24 17:08 hello_dir
-rw-r--r-- 1 root root 30 Oct 24 13:44 lower1.txt
-rw-r--r-- 1 root root 30 Oct 24 13:44 lower2.txt
-rw-r--r-- 1 root root 30 Oct 24 13:44 lower3.txt
[root@docker merged]# tree
.
├── hello_dir
│   ├── hello.1.txt
│   ├── hello.2.txt
│   ├── hello.3.txt
│   └── hello.txt
├── lower1.txt
├── lower2.txt
└── lower3.txt

1 directory, 7 files
```
可以看到各个子文件夹下的lower1.txt，lower2.txt和lower3.txt合并到了merged文件夹下，各个子文件夹下的hello_dir只保留一个，但是hello_dir下面的文件hello1.txt，hello2.txt和hello3.txt合并过来了。不同的是，hello.txt只保留了一份。

根据前面的学习，merged/hello_dir/hello.txt中应该保留的是lower1/hello_dir/hello.txt文件的内容。
```sh
[root@docker merged]# cat hello_dir/hello.txt 
hello1.txt
```
果然如此。

### 删除文件/文件夹
1. 文件/文件夹在upperdir目录，且底层的lowerdir中不存在同名的文件/文件夹
由于upper目录是可以直接`读写`的。当删除这种类型的文件或者文件夹时，会直接从upper目录删除。

我们首先在merged中创建一个upper.txt文件：
```sh
[root@docker merged]# touch upper.txt
[root@docker merged]# ll
total 12
drwxr-xr-x 1 root root 42 Oct 24 17:08 hello_dir
-rw-r--r-- 1 root root 30 Oct 24 13:44 lower1.txt
-rw-r--r-- 1 root root 30 Oct 24 13:44 lower2.txt
-rw-r--r-- 1 root root 30 Oct 24 13:44 lower3.txt
-rw-r--r-- 1 root root  0 Oct 24 17:56 upper.txt
```
此时查看可以发现该文件存在于upper目录，并且在各lower目录中不存在同名文件。
```sh
[root@docker mytest]# tree
.
├── lower1
│   ├── hello_dir
│   │   ├── hello.1.txt
│   │   └── hello.txt
│   └── lower1.txt
├── lower2
│   ├── hello_dir
│   │   ├── hello.2.txt
│   │   └── hello.txt
│   └── lower2.txt
├── lower3
│   ├── hello_dir
│   │   ├── hello.3.txt
│   │   └── hello.txt
│   └── lower3.txt
├── merged
│   ├── hello_dir
│   │   ├── hello.1.txt
│   │   ├── hello.2.txt
│   │   ├── hello.3.txt
│   │   └── hello.txt
│   ├── lower1.txt
│   ├── lower2.txt
│   ├── lower3.txt
│   └── upper.txt
├── upper
│   └── upper.txt
└── work
    └── work
```

我们在merged中删除文件upper.txt，然后查看upper目录：
```sh
[root@docker merged]# rm -f upper.txt
[root@docker upper]# ll
total 0
```
2. 要删除的文件或目录来自lower层，upper层不存在覆盖文件
**OverlayFS**针对这种情况采用whiteout文件。
**Whiteout**在upper目录中创建，用于屏蔽底层的同名文件。同时，该文件在merge层是不可见的，所以用户就看不到被删除的文件或者目录了。

**Whiteout**文件并不是普通的文件，而是主次设备号都为0的字符设备（可以通过"mknod <name> c 0 0"命令手工创建）。
当用户在merge层通过ls命令检查父目录的目录项时，OverlayFS会自动过滤掉和whiteout文件自身以及和它同名的lower层文件和目录，达到了隐藏文件的目的，让用户以为文件已经删除了。

以lower1.txt为例，它来自lower1，并且在upper中不存同名文件。
```sh
[root@docker merged]# rm -f lower1.txt 
[root@docker merged]# ll
total 8
drwxr-xr-x 1 root root 42 Oct 24 17:08 hello_dir
-rw-r--r-- 1 root root 30 Oct 24 13:44 lower2.txt
-rw-r--r-- 1 root root 30 Oct 24 13:44 lower3.txt
[root@docker merged]# ll ../upper/
total 0
c--------- 1 root root 0, 0 Oct 24 18:14 lower1.txt
[root@docker merged]# ll ../lower1/
total 4
drwxr-xr-x 2 root root 42 Oct 24 17:08 hello_dir
-rw-r--r-- 1 root root 30 Oct 24 13:44 lower1.txt
```
可以看出删除后，在merged中看不到文件lower1.txt，在lower1文件夹中依然存在。在upper文件夹中出现了一个lower1.txt的字符设别文件（c），并且设备号是(0,0)。

3. 要删除的文件是upper层覆盖lower层的文件，要删除的目录是上下层合并的目录
这种情况就是前两种情况的合并。
OverlayFS需要首先在upper中删掉同名文件/目录，然后再创建同名的Whiteout文件。

### 增加文件/文件夹
1. 全新的创建一个文件/目录
此种情况最简单，由于在upper层和lower层都不存在同名的文件，那么直接在upper层创建文件/目录即可。
2. 创建一个lower层存在，但是在upper层中存在同名Whiteout同名文件的文件
只需要将upper层中的Whiteout文件删除，然后创建新的同名文件就可以了。
3. 创建一个lower层存在，但是在upper层中存在同名Whiteout文件的同名目录
此种情况下不能按照2类型操作，因为上下层同名的目录是合并，而不是覆盖。
为此，OverlayFS引入了Opaque属性：需要在upper对应的目录上设置"trusted.overlay.opaque"该扩展属性来实现。
所以需要upper层所在的文件系统支持xattr扩展属性。

**OverlayFS**在读取上下层存在同名目录的目录项时，如果upper层的目录被设置了opaque属性，它将忽略这个目录在下层的所有同名目录中的目录项，以保证新建的目录是一个空的目录。

### 修改文件
1. 如果文件来自upper层，那直接写入即可。
2. 如果文件来自lower层，由于lower层文件无法修改，因此需要先复制到upper层，然后再往其中写入内容，这就是OverlayFS的写时复制（copy-up）特性。

## Copyup特性
OverlayFS触发Copyup特性的操作如下：
1. 用户以写方式打开来自lower层的文件时，对该文件执行copyup，即open()系统调用时带有O_WRITE或O_RDWR等标识；
2. 修改来自lower层文件或目录属性或者扩展属性时，对该文件或目录触发copyup，例如chmod、chown或设置acl属性等；
3. rename来自lower层文件时，对该文件执行copyup；
4. 对来自lower层的文件创建硬链接时，对链接原文件执行copyup；
5. 在来自lower层的目录里创建文件、目录、链接等内容时，对其父目录执行copyup；
6. 对来自lower层某个文件或目录进行删除、rename、或其它会触发copy-up的动作时，其对应的父目录会至下而上递归执行copy-up。

## Rename特性
**mv**命令移动或rename文件时，首先会尝试调用`rename`系统调用直接由内核完成文件的renmae操作，但对于个别文件系统内核如果不支持rename系统调用，那由mv工具操作，它会首先复制一个一模一样的文件到目标位置，然后删除原来的文件，从而模拟达到类似的效果，但是这有一个很大的缺点就是无法保证整个rename过程的原子性。

对于OverlayFS来说，`文件`的rename系统调用是支持的，但是`目录`的rename系统调用支持需要分情况讨论。

在挂载文件系统时，内核提供了一个挂载选项"redirect_dir=on/off"，默认的启用情况由内核的OVERLAY_FS_REDIRECT_DIR配置选项决定。
1. 在未启用情况下，针对单纯来自upper层的目录是支持rename系统调用的，而对于来自lower层的目录或是上下层合并的目录则不支持，rename系统调用会返回-EXDEV，由mv工具负责处理；
2. 在启用的情况下，无论目录来自哪一层，是否合并都将支持rename系统调用，但是该特性非向前兼容，目前内核中默认是关闭的，用户可手动开启。

当开启redirect_dir属性时，OverlayFS设计了一种redirect xattr的扩展属性，其内容是lower层原始目录的相对路径（相对lower层挂载根目录或当前rename目录的父目录），设置在`upper层中的目标目录上`，并不会copyup原始目录中的子目录或文件。
用户通过merge目录扫描目录项时，overlayfs在扫描upper层目录时会检查它的redirect xattr扩展属性并找到原始lower层目录，同时将原始目录下的目录项也返回给用户。

## 原子性保证
在挂载overlay文件系统到merged时，还指定了一个work目录。
原子性保证由借助work目录实现。




