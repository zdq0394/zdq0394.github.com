#! /bin/bash
DISK="/dev/sdb"
DISK_NUM="100"

mkfs.ext4 $DISK
DISK_UUID=`blkid -s UUID -o value $DISK`
mkdir /mnt/$DISK_UUID
mount -t ext4 $DISK /mnt/$DISK_UUID

echo UUID=$DISK_UUID /mnt/$DISK_UUID ext4 defaults 0 2 | tee -a /etc/fstab


mkdir -p /mnt/fast-disks
for i in $(seq 1 $DISK_NUM); do
  mkdir -p /mnt/${DISK_UUID}/vol${i} /mnt/fast-disks/${DISK_UUID}_vol${i}
  mount --bind /mnt/${DISK_UUID}/vol${i} /mnt/fast-disks/${DISK_UUID}_vol${i}
done

for i in $(seq 1 $DISK_NUM); do
  echo /mnt/${DISK_UUID}/vol${i} /mnt/fast-disks/${DISK_UUID}_vol${i} none bind 0 0 | tee -a /etc/fstab
done