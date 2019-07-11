# XFS磁盘（文件）碎片查看和整理
## 工具包
* xfsdump: Administrative utilities for the XFS filesystem 
* xfslibs-dev: XFS filesystem-specific static libraries and headers
* xfsprogs: Utilities for managing the XFS filesystem 

## 查看碎片
``` sh
xfs_db -c frag -r /dev/sdc1
actual 93133, ideal 8251, fragmentation factor 91.14%
```

## 整理碎片
``` sh
xfs_fsr /dev/sdc1
```