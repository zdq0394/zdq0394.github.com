# 容器及其layer存储分析
本文接上篇[镜像及其layer存储分析](image_layout.md)继续。

## 容器目录
默认情况下，容器的相关的数据保存在目录`/var/lib/docker/containers`下面。
以nginx:latest创建一个容器，并不启动它。可以发现在一个和容器ID同名的目录出现在了`/var/lib/docker/containers`下面。
```sh
[root@localhost containers]# pwd
/var/lib/docker/containers
[root@localhost containers]# docker create nginx
4f0e4cc32ad2e846f0df0ca08df4be38b7a17876f66dfe055feab55ac527be3c
[root@localhost containers]# ls
4f0e4cc32ad2e846f0df0ca08df4be38b7a17876f66dfe055feab55ac527be3c
```

创建一个容器，相当于在镜像顶层之上增加了一个层（可读可写），那这个新的层在哪里呢？
这个层和镜像层一样都保存在`/var/lib/docker/image/overlay2/layerdb`下面。不同的是，镜像的layer保存在子目录sha256下面，而容器层保存在子目录mounts下面。
```
[root@localhost mounts]# pwd
/var/lib/docker/image/overlay2/layerdb/mounts
[root@localhost mounts]# ll
total 0
drwxr-xr-x 2 root root 51 Nov  9 09:21 4f0e4cc32ad2e846f0df0ca08df4be38b7a17876f66dfe055feab55ac527be3c
[root@localhost mounts]# cd 4f0e4cc32ad2e846f0df0ca08df4be38b7a17876f66dfe055feab55ac527be3c/
[root@localhost 4f0e4cc32ad2e846f0df0ca08df4be38b7a17876f66dfe055feab55ac527be3c]# ls
init-id  mount-id  parent
```
可以发现在容器下面包含3各文件：
* parent：引用的镜像的最顶层的chainID。
* init-id：在storage-driver中init层的目录
* mount-id：在storage-driver中容器层的目录
```sh
[root@localhost 4f0e4cc32ad2e846f0df0ca08df4be38b7a17876f66dfe055feab55ac527be3c]# cat parent 
sha256:160a8bd939a9421818f499ba4fbfaca3dd5c86ad7a6b97b6889149fd39bd91dd
[root@localhost 4f0e4cc32ad2e846f0df0ca08df4be38b7a17876f66dfe055feab55ac527be3c]# cat init-id 
89dbd3a7893baa0efbf8f77ac58b3192561fd62891531eb73d68feb1e600af06-init
[root@localhost 4f0e4cc32ad2e846f0df0ca08df4be38b7a17876f66dfe055feab55ac527be3c]# cat mount-id 
89dbd3a7893baa0efbf8f77ac58b3192561fd62891531eb73d68feb1e600af06
```
查看storage-driver(overlay2)下面出现了2各文件夹，和init-id和mount-id一致。
```sh
[root@localhost overlay2]# pwd
/var/lib/docker/overlay2
[root@localhost overlay2]# ll | grep 89dbd3
drwx------  5 root root 89dbd3a7893baa0efbf8f77ac58b3192561fd62891531eb73d68feb1e600af06
drwx------  5 root root 89dbd3a7893baa0efbf8f77ac58b3192561fd62891531eb73d68feb1e600af06-init
```

```sh
[root@localhost overlay2]# ls 89dbd3a7893baa0efbf8f77ac58b3192561fd62891531eb73d68feb1e600af06-init
diff  link  lower  merged  work
[root@localhost overlay2]# cat 89dbd3a7893baa0efbf8f77ac58b3192561fd62891531eb73d68feb1e600af06-init/link 
FEWHQ7576N2NZ4QEAGUFHVHSY5
[root@localhost overlay2]# cat 89dbd3a7893baa0efbf8f77ac58b3192561fd62891531eb73d68feb1e600af06-init/lower 
l/V47ZAVU47VNVE3B7TVCZIGKGOV:l/NUMROUBW7TBBLT56IWT4OL53EZ:l/MVB5STDEZWHO54D642CLYZYNEH

[root@localhost overlay2]# ls 89dbd3a7893baa0efbf8f77ac58b3192561fd62891531eb73d68feb1e600af06
diff  link  lower  merged  work
[root@localhost overlay2]# cat 89dbd3a7893baa0efbf8f77ac58b3192561fd62891531eb73d68feb1e600af06/link 
YMY2R223JESTB3XLXXGGSIXARB
[root@localhost overlay2]# cat 89dbd3a7893baa0efbf8f77ac58b3192561fd62891531eb73d68feb1e600af06/lower 
l/FEWHQ7576N2NZ4QEAGUFHVHSY5:l/V47ZAVU47VNVE3B7TVCZIGKGOV:l/NUMROUBW7TBBLT56IWT4OL53EZ:l/MVB5STDEZWHO54D642CLYZYNEH
```
通过检查lower文件可以发现，89dbd3a7893baa0efbf8f77ac58b3192561fd62891531eb73d68feb1e600af06-init层的底层是镜像的3个层，而89dbd3a7893baa0efbf8f77ac58b3192561fd62891531eb73d68feb1e600af06的底层包括4各层，分别是89dbd3a7893baa0efbf8f77ac58b3192561fd62891531eb73d68feb1e600af06-init层以及镜像的3个层。

## 启动容器
容器启动之前发现当前层是空的，并且文件系统没有挂载，merged下面也是空的。
```sh
[root@localhost 89dbd3a7893baa0efbf8f77ac58b3192561fd62891531eb73d68feb1e600af06]# ll diff/
total 0
[root@localhost 89dbd3a7893baa0efbf8f77ac58b3192561fd62891531eb73d68feb1e600af06]# ll merged/
total 0
```
然后启动容器
```sh
[root@localhost 89dbd3a7893baa0efbf8f77ac58b3192561fd62891531eb73d68feb1e600af06]# ll diff/
total 0
drwxr-xr-x. 3 root root 38 Nov  9 10:03 run
drwxr-xr-x. 3 root root 19 Apr 26  2018 var
[root@localhost 89dbd3a7893baa0efbf8f77ac58b3192561fd62891531eb73d68feb1e600af06]# ll merged/
total 8
drwxr-xr-x. 2 root root 4096 Apr 26  2018 bin
drwxr-xr-x. 2 root root    6 Feb 24  2018 boot
drwxr-xr-x. 1 root root   43 Nov  9 09:21 dev
drwxr-xr-x. 1 root root   66 Nov  9 09:21 etc
drwxr-xr-x. 2 root root    6 Feb 24  2018 home
drwxr-xr-x. 1 root root   45 Apr 26  2018 lib
drwxr-xr-x. 2 root root   34 Apr 26  2018 lib64
drwxr-xr-x. 2 root root    6 Apr 26  2018 media
drwxr-xr-x. 2 root root    6 Apr 26  2018 mnt
drwxr-xr-x. 2 root root    6 Apr 26  2018 opt
drwxr-xr-x. 2 root root    6 Feb 24  2018 proc
drwx------. 2 root root   37 Apr 26  2018 root
drwxr-xr-x. 1 root root   38 Nov  9 10:03 run
drwxr-xr-x. 2 root root 4096 Apr 26  2018 sbin
drwxr-xr-x. 2 root root    6 Apr 26  2018 srv
drwxr-xr-x. 2 root root    6 Feb 24  2018 sys
drwxrwxrwt. 1 root root    6 Apr 30  2018 tmp
drwxr-xr-x. 1 root root   66 Apr 26  2018 usr
drwxr-xr-x. 1 root root   19 Apr 26  2018 var
```
并且可以发现文件系统已经挂载。
```sh
[root@dqvm 89dbd3a7893baa0efbf8f77ac58b3192561fd62891531eb73d68feb1e600af06]# df -h
Filesystem               Size  Used Avail Use% Mounted on
//忽略无关文件系统
overlay                   26G   18G  8.5G  68% /var/lib/docker/overlay2/89dbd3a7893baa0efbf8f77ac58b3192561fd62891531eb73d68feb1e600af06/merged
shm                       64M     0   64M   0% /var/lib/docker/containers/4f0e4cc32ad2e846f0df0ca08df4be38b7a17876f66dfe055feab55ac527be3c/shm
```
挂载的详情信息：
```sh
[root@dqvm 89dbd3a7893baa0efbf8f77ac58b3192561fd62891531eb73d68feb1e600af06]# mount
overlay on /var/lib/docker/overlay2/89dbd3a7893baa0efbf8f77ac58b3192561fd62891531eb73d68feb1e600af06/merged type overlay (rw,relatime,lowerdir=/var/lib/docker/overlay2/l/FEWHQ7576N2NZ4QEAGUFHVHSY5:/var/lib/docker/overlay2/l/V47ZAVU47VNVE3B7TVCZIGKGOV:/var/lib/docker/overlay2/l/NUMROUBW7TBBLT56IWT4OL53EZ:/var/lib/docker/overlay2/l/MVB5STDEZWHO54D642CLYZYNEH,upperdir=/var/lib/docker/overlay2/89dbd3a7893baa0efbf8f77ac58b3192561fd62891531eb73d68feb1e600af06/diff,workdir=/var/lib/docker/overlay2/89dbd3a7893baa0efbf8f77ac58b3192561fd62891531eb73d68feb1e600af06/work)

shm on /var/lib/docker/containers/4f0e4cc32ad2e846f0df0ca08df4be38b7a17876f66dfe055feab55ac527be3c/shm type tmpfs (rw,nosuid,nodev,noexec,relatime,size=65536k)

```
