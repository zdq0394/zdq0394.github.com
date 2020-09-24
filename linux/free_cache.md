# 清理cache
可以通过 drop_caches 的方式来清理：
*. 清理page cache：$ echo 1 > /proc/sys/vm/drop_caches
*. 清理dentries和inodes：$ echo 2 > /proc/sys/vm/drop_caches
*. 清理page cache、dentries和inodes：$ echo 3 > /proc/sys/vm/drop_caches