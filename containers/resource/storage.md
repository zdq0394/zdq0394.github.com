# 磁盘容量限制
## 系统要求
`overlay2.size`: Sets the default max size of the container.

It is supported only when the backing fs is `xfs` and mounted with `pquota` mount option. Under these conditions the user can pass any size less then the backing fs size.

xfs支持三种类型的quota：uquota、gquota和pquota：
* uquota/usrquota/quota/uqnoenforce/qnoenforce
        User disk quota accounting enabled, and limits (optionally) enforced.  Refer to xfs_quota(8) for further details.
* gquota/grpquota/gqnoenforce
        Group disk quota accounting enabled and limits (optionally) enforced.  Refer to xfs_quota(8) for further details.
* pquota/prjquota/pqnoenforce
        Project disk quota accounting enabled and limits (optionally) enforced.  Refer to xfs_quota(8) for further details.

docker的overlay2需要的是pquota，在/etc/fstab中设置：

`/dev/vdb /data xfs rw,pquota 0 0`

将/dev/vdb卸载后重新挂载:

`umount /dev/vdb`

`mount -a`

可以在/proc/mounts中看到已经被挂载的目录和参数：

`$ cat /proc/mounts  |grep vdb`

`/dev/vdb /data xfs rw,relatime,attr2,inode64,prjquota 0 0`

## 配置docker daemon
/etc/docker/daemon.json配置文件如下，这里将每个容器可以使用的磁盘空间设置为1G:
```json
{
    "data-root": "/data/docker",
    "storage-driver": "overlay2",
    "storage-opts": [
      "overlay2.override_kernel_check=true",
      "overlay2.size=1G"
    ]
}
```

## 测试
重启docker后，启动一个容器，在容器中创建文件。先创建一个1000M的文件：
```sh
/ # dd if=/dev/zero of=/a bs=100M count=10
10+0 records in
10+0 records out
```

然后创建第二个1000M的文件：

```sh
/ # dd if=/dev/zero of=/b bs=100M count=10
dd: writing '/b': No space left on device
2+0 records in
0+1 records out
```




