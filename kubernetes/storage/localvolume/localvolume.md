# 本地磁盘
本地磁盘功能（local volume storage）从1.14版本开始GA。
## 术语
* provisioner：指local-volume-provisioner程序，实际部署时会以daemonset方式部署，发现local volume，并作为local PVs提供。
* discovery directory：宿主节点上的一个目录，provisioner将从这里发现filesystem mode和block mode的local PVs。
* local PV：Kubernetes local persistent volume。
* filesystem local PV： Local PV with Filesystem mode。
* block local PV：Local PV with Block mode。

## 磁盘准备工作
本地磁盘包括两种：
* Filesystem mode volumes
* Block mode volumes
Provisioner通过`discovery directory`（provisioner的配置字段hostDir）发现可供使用的磁盘。
* 对于filesystem mode volumes，discovery directory包含它的挂载点
* 对于block mode volumes，discovery directory包含它的symbolic links
* 对于directory-based local volumes，必须bind-mounted到descovery directories。
### 创建discovery directory
* 该目录比如`/mnt/disks`，provisioner通过配置字段`hostDir`识别。
* 该目录仅能由一个storage class使用。
* 如果想配置多个storage class，每个storage class对应一个discovery directory。
* 一个provisioner可以配置多个storage class。每个storage class都要配置独立的discovery directory。

### 整个磁盘作为一个filesystem PV
假设:
* /mnt/fast-disks：discovery directory
* /dev/sdb：作为本地磁盘
```sh
mkdir -p /mnt/fast-disks
mkfs.ext4 /dev/sdb
DISK_UUID=$(blkid -s UUID -o value /dev/sdb)
mkdir /mnt/fast-disks/$DISK_UUID
mount -t ext4 /dev/sdb /mnt/fast-disks/$DISK_UUID

echo UUID=`blkid -s UUID -o value /dev/sdb` /mnt/fast-disks/$DISK_UUID ext4 defaults 0 2 | tee -a /etc/fstab

```
* 使用whole disk，可以进行IO isolation。
### 整个磁盘共享给多个filesysmte PVs
假设：
* /mnt/fast-disks：discovery directory
* /dev/sdb：作为本地磁盘
```sh
mkdir -p /mnt/fast-disks
mkfs.ext4 /dev/sdb
DISK_UUID=$(blkid -s UUID -o value /dev/sdb)
mkdir /mnt/$DISK_UUID
mount -t ext4 /dev/sdb /mnt/$DISK_UUID

echo UUID=`blkid -s UUID -o value /dev/sdb` /mnt/$DISK_UUID ext4 defaults 0 2 | tee -a /etc/fstab

for i in $(seq 1 10); do
  mkdir -p /mnt/${DISK_UUID}/vol${i} /mnt/fast-disks/${DISK_UUID}_vol${i}
  mount --bind /mnt/${DISK_UUID}/vol${i} /mnt/fast-disks/${DISK_UUID}_vol${i}
done

for i in $(seq 1 10); do
  echo /mnt/${DISK_UUID}/vol${i} /mnt/fast-disks/${DISK_UUID}_vol${i} none bind 0 0 | tee -a /etc/fstab
done
```
* 每个Local PVs共享相同的磁盘空间，并且没有空间隔离。

### Block PVs
假设：
* /mnt/fast-disks：discovery directory
* /dev/sdb：作为本地磁盘

为了安全，必须使用磁盘的`独一路径`。
如何发现磁盘的`独一路径`呢？
```sh
$ ls -l /dev/disk/by-id/
lrwxrwxrwx 1 root root  9 Apr 18 14:26 lvm-pv-uuid-kdWgMJ-OOfq-ox5N-ie4E-NU2h-8zPJ-edX1Og -> ../../sde
lrwxrwxrwx 1 root root  9 Apr 18 14:26 lvm-pv-uuid-VqD1G2-upe2-Xnek-PdXD-mkOT-LhSv-rUV2is -> ../../sdc
lrwxrwxrwx 1 root root  9 Apr 18 14:26 lvm-pv-uuid-yyTnct-TpUS-U93g-JoFs-6seh-Yy29-Dn6Irf -> ../../sdb
```
本例子中，/dev/sdb的独一路径就是`/dev/disk/by-id/lvm-pv-uuid-yyTnct-TpUS-U93g-JoFs-6seh-Yy29-Dn6Irf`

然后把该独一路径link到discovery directory：
```sh
ln -s /dev/disk/by-id/lvm-pv-uuid-yyTnct-TpUS-U93g-JoFs-6seh-Yy29-Dn6Irf /mnt/fast-disks
```
### 磁盘分区
上述针对磁盘的操作，都可以针对磁盘分区。进行磁盘分区再提供多个PVs（filesystem PV或者block PV）的好处是：空间隔离。

## 部署static-volume-provisioner
* [部署Daemonset](provisioner.yaml)
* [部署service](provisioner.svc.yaml)
* [部署storageclass](storageclass.yaml)

## 应用本地磁盘
[例子](statefulset.example.yaml)