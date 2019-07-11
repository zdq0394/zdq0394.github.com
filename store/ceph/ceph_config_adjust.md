# CEPH在线调整参数
## 查看整体配置
```
ceph --show-config | grep full
```
## tell方式设置
### 调整mon的参数

### 调整osd的参数
设置mon-osd-nearfull-ratio
```sh
ceph tell osd.* injectargs '--mon-osd-nearfull-ratio 0.80'
```

## daemon方式设置
这种方式设置需要登陆到进程(ceph-mon或者ceph-osd)所在的节点上。

### 获取参数
```sh
ceph daemon osd.1 config get mon_osd_full_ratio
```

### 修改配置
```sh
ceph daemon osd.1 config set mon_osd_full_ratio 0.97
```


## OSD Reweight
### 自动调节的工具
```
ceph osd reweight-by-utilization
```
