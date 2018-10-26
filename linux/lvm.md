# Logical Volume Manager简介
## 概述
PV，VG，LV构成了一种用于管理拥有一个或者多个硬盘的主机的工具——逻辑卷管理器（Logical Volume Manager,LVM）。
这些硬盘可能只有一个分区，也可以有多个分区。
在LVM看来，每个硬盘分区看做一个物理分区（physical volume，PV），通过将这些PV整合，组成一个卷组（volume group，VG）。
卷组（VG）就成了一个物理资源池，然后基于VG可以分配形成逻辑卷（Logical Volume，LV）。对操作系统来说，LV和PV没有区别，可以动态调整大小，并且大小可以超过一个单独的PV的大小。
## 实践
1. 创建物理卷
```sh
# pvcreate /dev/vdb1
  Physical volume "/dev/vdb1" successfully created.

# pvdisplay /dev/vdb1
  "/dev/vdb1" is a new physical volume of "595.00 GiB"
  --- NEW Physical volume ---
  PV Name               /dev/vdb1
  VG Name               
  PV Size               595.00 GiB
  Allocatable           NO
  PE Size               0   
  Total PE              0
  Free PE               0
  Allocated PE          0
  PV UUID               NHTGAR-Mww1-cZkR-UHNv-k39R-FAPX-n2cUKK

```
同样的命令创建pv /dev/vdc1。

现在可以看到有两块pv存在。
```sh
[root@keceph2 ~]# pvs
  PV         VG Fmt  Attr PSize   PFree  
  /dev/vdb1     lvm2 ---  595.00g 595.00g
  /dev/vdc1     lvm2 ---  395.00g 395.00g
```

2. 创建卷组
创建卷组命令如下：
```sh
# vgcreate myvg /dev/vdb1
  Volume group "myvg" successfully created
# vgs
  VG   #PV #LV #SN Attr   VSize   VFree  
  myvg   1   0   0 wz--n- 595.00g 595.00g
# pvs
  PV         VG   Fmt  Attr PSize   PFree  
  /dev/vdb1  myvg lvm2 a--  595.00g 595.00g
  /dev/vdc1       lvm2 ---  395.00g 395.00g
```
可以看到myvg创建了，初始包括一个pv /dev/vdb1。通过命令`pvs`也可以看到其VG列显示了它的VG。其实通过pvdisplay还可以看出更多信息。

3. 扩展卷组
扩展卷组命令如下：
```sh
# vgextend myvg /dev/vdc1
  Volume group "myvg" successfully extended
# pvs
  PV         VG   Fmt  Attr PSize   PFree  
  /dev/vdb1  myvg lvm2 a--  595.00g 595.00g
  /dev/vdc1  myvg lvm2 a--  395.00g 395.00g
```
可以看出两块pv都加入了vg。通过查看vg，可以发现vg包括了2块PV，vg的大小是两块pv之和。目前该pv还没有分配lv。
```sh
# vgs
  VG   #PV #LV #SN Attr   VSize   VFree  
  myvg   2   0   0 wz--n- 989.99g 989.99g
```

4. 分配lv
```sh
# lvcreate -L 700G -n mylv1 myvg
  Logical volume "mylv1" created.
# lvs
  LV    VG   Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  mylv1 myvg -wi-a----- 700.00g                                                    
# pvs
  PV         VG   Fmt  Attr PSize   PFree  
  /dev/vdb1  myvg lvm2 a--  595.00g      0 
  /dev/vdc1  myvg lvm2 a--  395.00g 289.99g
# vgs
  VG   #PV #LV #SN Attr   VSize   VFree  
  myvg   2   1   0 wz--n- 989.99g 289.99g
```
我们创建了一块700G的logical volume（它的大小超过了任何一个pv的大小）。
通过pvs可以发现，vg实际上将pv /dev/vdb1的所有空间和pv /dev/vdc1的一部分分配给了mylv。

通过lsblk命令也可以发现mylv跨了2个磁盘分区。
```sh
# lsblk
NAME           MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sr0             11:0    1  436K  0 rom  
vda            253:0    0   20G  0 disk 
├─vda1         253:1    0    1G  0 part /boot
└─vda2         253:2    0   19G  0 part /
vdb            253:16   0  600G  0 disk 
├─vdb1         253:17   0  595G  0 part 
│ └─myvg-mylv1 252:0    0  700G  0 lvm  
└─vdb2         253:18   0    5G  0 part 
vdc            253:32   0  400G  0 disk 
├─vdc1         253:33   0  395G  0 part 
│ └─myvg-mylv1 252:0    0  700G  0 lvm  
└─vdc2         253:34   0    5G  0 part 
```
通过如下命令，可以发现/dev/myvg/mylv1和/dev/dm-0是一个东西。
```sh
# ll /dev/dm-0 
brw-rw---- 1 root disk 252, 0 Oct 26 11:13 /dev/dm-0
# ll /dev/myvg/
total 0
lrwxrwxrwx 1 root root 7 Oct 26 11:13 mylv1 -> ../dm-0
# dmsetup ls
myvg-mylv1	(252:0)
# ll /dev/mapper/
total 0
crw------- 1 root root 10, 236 Oct  6 21:30 control
lrwxrwxrwx 1 root root       7 Oct 26 11:21 myvg-mylv1 -> ../dm-0
```

5. 创建文件系统
```sh
# mkfs.ext4 /dev/myvg/mylv1 
mke2fs 1.42.9 (28-Dec-2013)
Filesystem label=
OS type: Linux
Block size=4096 (log=2)
Fragment size=4096 (log=2)
Stride=0 blocks, Stripe width=0 blocks
45875200 inodes, 183500800 blocks
9175040 blocks (5.00%) reserved for the super user
First data block=0
Maximum filesystem blocks=2332033024
5600 block groups
32768 blocks per group, 32768 fragments per group
8192 inodes per group
Superblock backups stored on blocks: 
	32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632, 2654208, 
	4096000, 7962624, 11239424, 20480000, 23887872, 71663616, 78675968, 
	102400000

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (32768 blocks): done
Writing superblocks and filesystem accounting information: done  
```
mount lv
```sh
# mkdir -p /mnt/mypvtest
# mount /dev/myvg/mylv1 /mnt/mypvtest/
# cd /mnt/mypvtest/
# ls
lost+found
```


