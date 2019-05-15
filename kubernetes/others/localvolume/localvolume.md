# 本地磁盘实践
## 准备磁盘
* /mnt/fast-disks：本地磁盘的discovery directory
* /dev/sdb：作为本地磁盘
### filesystem mode
mkdir -p /mnt/fast-disks
mkfs.ext4 /dev/sdb
DISK_UUID=$(blkid -s UUID -o value /dev/sdb)
mkdir /mnt/$DISK_UUID
mount -t ext4 /dev/sdb /mnt/$DISK_UUID

echo UUID=`sudo blkid -s UUID -o value /dev/sdb` /mnt/$DISK_UUID ext4 defaults 0 2 | tee -a /etc/fstab

for i in $(seq 1 10); do
  mkdir -p /mnt/${DISK_UUID}/vol${i} /mnt/fast-disks/${DISK_UUID}_vol${i}
  mount --bind /mnt/${DISK_UUID}/vol${i} /mnt/fast-disks/${DISK_UUID}_vol${i}
done

for i in $(seq 1 10); do
  echo /mnt/${DISK_UUID}/vol${i} /mnt/fast-disks/${DISK_UUID}_vol${i} none bind 0 0 | tee -a /etc/fstab
done

## 部署static-volume-provisioner
* [部署Daemonset](provisioner.yaml)
* [部署service](provisioner.svc.yaml)
* [部署storageclass](storageclass.yaml)

## 使用准备
[例子](statefulset.example.yaml)