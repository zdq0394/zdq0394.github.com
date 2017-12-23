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

## How the `overlay2` driver works
OverlayFS layers **two directories** on a single Linux host and presents them as **a single directory**。这些目录被称为`layers`，unification process被成为`union mount`。
在OverlayFS中，lower directory称为`lowerdir`；upper directory称为`updir`；联合后的统一的视图称为`merged`。

`overlay` driver仅仅支持一个lower OverlayFS layer，因此需要hard links去实现一个多层的镜像。

`overlay2` driver原生支持128个lower OverlayFS层。这大大提高了layer-related的docker命令：比如docker build，docker commit的性能，并减少了backing filesystem中inodes的消耗。

### Image and container layers on-disk
首先`docker pull`一个镜像
```sh
# docker pull registry.docker-cn.com/library/redis
Using default tag: latest
latest: Pulling from library/redis
c4bb02b17bb4: Pull complete 
58638acf67c5: Pull complete 
f98d108cc38b: Pull complete 
83be14fccb07: Pull complete 
5d5f41793421: Pull complete 
ed89ff0d9eb2: Pull complete 
Digest: sha256:08a00f8a12d04a3a49c861552d99479e8c56f1e77e00129ec5c2772fe41a3b58
Status: Downloaded newer image for registry.docker-cn.com/library/redis:latest
```
镜像有6层，然后查看`/var/lib/docker/overlay2`，发现有7个目录。
```sh
/var/lib/docker/overlay2# ll
total 36
drwx------  9 root root 4096 Dec 22 10:49 ./
drwx--x--x 14 root root 4096 Dec 15 21:29 ../
drwx------  5 root root 4096 Dec 22 10:49 081f5f7009dca18e1d09f315e356f65b1ff95abd87b723dba98b8e653fe52d7d/
drwx------  5 root root 4096 Dec 22 10:49 27bcb312b4887e1d93a6330e7eaa10adc6460f2e2e14788e90282979b10af067/
drwx------  5 root root 4096 Dec 22 10:49 433d9c46990dcb965b7942e07b5c8a550669bb8fc8384f2025e1f1098ba117cc/
drwx------  5 root root 4096 Dec 22 10:49 66ec047aefb69942e53d8db652c1947f322b61f44bfb61dc0768734a15d2fa7e/
drwx------  5 root root 4096 Dec 22 10:49 c9952ce59340a5d317861b538a143225e9516c9eb311354d6831354c0d590161/
drwx------  3 root root 4096 Dec 22 10:49 f32d5e1f81cfa514bb2fadc1047312853f745f5d48148d8ab21d3352b06c3946/
drwx------  2 root root 4096 Dec 22 10:49 l/
```
查看`l`目录可见，包含了6个符号链接，分别指向6个层的diff目录。
```sh
/var/lib/docker/overlay2# ls -la l
total 32
drwx------ 2 root root 4096 Dec 22 10:49 .
drwx------ 9 root root 4096 Dec 22 10:49 ..
lrwxrwxrwx 1 root root   72 Dec 22 10:49 2TX5XYYH36IZFXMYZLSKXNBR5Z -> ../27bcb312b4887e1d93a6330e7eaa10adc6460f2e2e14788e90282979b10af067/diff
lrwxrwxrwx 1 root root   72 Dec 22 10:49 76HFDMVWSRDLXRA434A342QVAG -> ../433d9c46990dcb965b7942e07b5c8a550669bb8fc8384f2025e1f1098ba117cc/diff
lrwxrwxrwx 1 root root   72 Dec 22 10:49 KJE7GZXOVHR52Y3QV6LZ245SW3 -> ../c9952ce59340a5d317861b538a143225e9516c9eb311354d6831354c0d590161/diff
lrwxrwxrwx 1 root root   72 Dec 22 10:49 U2FDPHHAMBUCNLRHN3MJXTA5JX -> ../66ec047aefb69942e53d8db652c1947f322b61f44bfb61dc0768734a15d2fa7e/diff
lrwxrwxrwx 1 root root   72 Dec 22 10:49 XS2PHAZZD744O3EKI4QR3VWKJX -> ../f32d5e1f81cfa514bb2fadc1047312853f745f5d48148d8ab21d3352b06c3946/diff
lrwxrwxrwx 1 root root   72 Dec 22 10:49 ZEEWKZCFLEZFQHH74UA5M5S7V2 -> ../081f5f7009dca18e1d09f315e356f65b1ff95abd87b723dba98b8e653fe52d7d/diff
```

通过命令：
``sh
/var/lib/docker/overlay2# ls *
081f5f7009dca18e1d09f315e356f65b1ff95abd87b723dba98b8e653fe52d7d:
diff  link  lower  merged  work

27bcb312b4887e1d93a6330e7eaa10adc6460f2e2e14788e90282979b10af067:
diff  link  lower  merged  work

433d9c46990dcb965b7942e07b5c8a550669bb8fc8384f2025e1f1098ba117cc:
diff  link  lower  merged  work

66ec047aefb69942e53d8db652c1947f322b61f44bfb61dc0768734a15d2fa7e:
diff  link  lower  merged  work

c9952ce59340a5d317861b538a143225e9516c9eb311354d6831354c0d590161:
diff  link  lower  merged  work

f32d5e1f81cfa514bb2fadc1047312853f745f5d48148d8ab21d3352b06c3946:
diff  link

l:
2TX5XYYH36IZFXMYZLSKXNBR5Z  76HFDMVWSRDLXRA434A342QVAG  KJE7GZXOVHR52Y3QV6LZ245SW3  U2FDPHHAMBUCNLRHN3MJXTA5JX  XS2PHAZZD744O3EKI4QR3VWKJX  ZEEWKZCFLEZFQHH74UA5M5S7V2
```
可见f32d5e1f81cfa514bb2fadc1047312853f745f5d48148d8ab21d3352b06c3946是最lowest的一层，包含2个元素：
* link：文件，包含的是short identifier，和l中软链接一致。
* diff：包含本层的内容

除了最lowest的一层，其它各层又包含了lower文件和merged、work两个目录。
* lower：文件，包含该层依赖的所有底层的short identifier。
* merged：包含的是本层和所有底层的union
* work： 被OverlayFS内部使用的目录


## How container reads and writes work with overlay or overlay2
### Reading files
* **The file does not exist in the container layer**：从image(lowerdir)读取，性能损失很小。
* **The file only exists in the container layer**：直接从container(upperdir)读取。
* **The file exists in both the container layer and the image layer**：从container(upperdir)读取，image(lowerdir)中的文件被隐藏。

### Modifying files or directories
**Writing to a file for the first time**

**Deleting files and directories**

**Renaming directories**

## OverlayFS and Docker Performance
`overlay`和`overlay2` storage driver都比`aufs`性能好。
在某些情况下，`overlay2`甚至比`btrfs`性能都好。