#! /bin/bash
mkfs.ext4 /dev/sdb

mkdir -p /mnt/fast-disks

DISK_UUID=$(blkid -s UUID -o value /dev/sdb)
mkdir /mnt/$DISK_UUID
mount -t ext4 /dev/sdb /mnt/$DISK_UUID

echo UUID=`sudo blkid -s UUID -o value /dev/sdb` /mnt/$DISK_UUID ext4 defaults 0 2 | tee -a /etc/fstab

for i in $(seq 1 100); do
  mkdir -p /mnt/${DISK_UUID}/vol${i} /mnt/fast-disks/${DISK_UUID}_vol${i}
  mount --bind /mnt/${DISK_UUID}/vol${i} /mnt/fast-disks/${DISK_UUID}_vol${i}
done

for i in $(seq 1 100); do
  echo /mnt/${DISK_UUID}/vol${i} /mnt/fast-disks/${DISK_UUID}_vol${i} none bind 0 0 | tee -a /etc/fstab
done