# Storage Driver overlay/overlay2
**OverlayFS**是联合文件系统（union filesystem）的一种。
与其说是一种文件系统，不如说是一种mounting机制（It is more of a mounting mechanism than a file system）。

**OverlayFS**是一种堆叠文件系统，它依赖并建立在其它的文件系统之上（ext4/xfs等）。
并不直接参与磁盘空间结构的划分，仅仅是将来自底层文件系统中不同的目录进行“合并”，然后向用户呈现。
因此，对于用户来说，见到的OverlayFS文件系统根目录下的内容就来自挂载时指定的不同目录的“合集”。

**OverlayFS**最基本的特性，简单的总结为以下3点：
* 上下层同名目录合并
* 上下层同名文件覆盖
* lower dir文件写时拷贝
以上这三点对用户都是不被感知的。

由于overlay2技术已经相对成熟，并且主流linux发行版都已经支持，我们只讨论overlay2。
不建议使用overlay。
## How the `overlay2` driver works
在OverlayFS中
* lower directory称为`lowerdir`，可以有多个层次，并且层次之间具有依赖关系；
* upper directory称为`updir`；
* 联合后的统一的视图称为`merged`；
* 另外`work`目录由OverlayFS使用（可以借助此来实现一致性）

`overlay2` driver原生支持128个lower OverlayFS层。

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
查看`l`目录可见，包含了6个符号链接，分别指向6个层的diff目录。这主要时为了简化overlayfs挂载时的路径长度。

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
```sh
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
可见f32d5e1f81cfa514bb2fadc1047312853f745f5d48148d8ab21d3352b06c3946是最底的一层，包含2个元素：
* link：文件，包含的是short identifier，和l中软链接一致。
* diff：包含本层的内容，也就是OverlayFS中的upperdir。

除了最底的一层，其它各层又包含了lower文件和merged、work两个目录。
* lower：文件，包含该层依赖的所有底层的short identifier，指定了OverlayFS中的lowerdir。
* merged：OverlayFS的挂载点，包含的是diff和lower文件中指定的层中的内容。
* work： 被OverlayFS内部使用的目录。

## How container reads and writes work with overlay or overlay2
### Reading files
* **The file does not exist in the container layer**：从image(lowerdir)读取，性能损失很小。
* **The file only exists in the container layer**：直接从container(upperdir)读取。
* **The file exists in both the container layer and the image layer**：从container(upperdir)读取，image(lowerdir)中的文件被隐藏。

### Modifying files or directories
**Writing to a file for the first time**

`overlay/overlay2` driver执行`copy_up`：将文件从`image(lowerdir)`拷贝到`container(upperdir)`。
容器然后将变更写到容器层的副本中。

OverlayFS works at the `file level` rather than the `block level`。

**Deleting files and directories**

* whiteout file
* opaque directory

**Renaming directories**

Calling rename(2) for a directory is allowed only when both the source and the destination path are on the top layer. Otherwise, it returns EXDEV error (“cross-device link not permitted”)。

## 参考
* [Linux OverlayFS](../../linux/overlayfs.md)