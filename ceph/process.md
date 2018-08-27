# Ceph daemon管理
## Redhat类操作系统
### 所有进程
1. All Ceph Daemons：
```sh
systemctl start ceph.target
systemctl stop ceph.target
systemctl status ceph.target
```
### 某类型进程
1. All Monitor Daemons:
```sh
systemctl start ceph-mon.target
systemctl stop ceph-mon.target
systemctl status ceph-mon.target
```

2. All OSD Daemons:
```sh
systemctl start ceph-osd.target
systemctl stop ceph-osd.target
systemctl status ceph-osd.target
```

3. All RADOSGW Daemons:
```sh
systemctl start ceph-radosgw.target
systemctl stop ceph-radosgw.target
systemctl status ceph-radosgw.target
```
### 某个进程
1. Some Monitor Daemon:
ceph-mon@<HOSTNAME>
```sh
systemctl start ceph-mon@keceph1
systemctl stop ceph-mon@keceph1
systemctl status ceph-mon@keceph1
```

2. Some OSD Daemon:
ceph-osd@<OSD_number>
```sh
systemctl start ceph-osd@0
systemctl stop ceph-osd@0
systemctl status ceph-osd@0
```

3. Some RADOSGW Daemon:
ceph-radosgw@rgw.<gateway_hostname>
```sh
systemctl start ceph-radosgw@rgw.keceph1
systemctl stop ceph-radosgw@rgw.keceph1
systemctl status ceph-radosgw@rgw.keceph1
```