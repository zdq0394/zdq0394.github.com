# 系统优化
1. /proc/sys/kernel/pid_max；可以在/etc/sysctl.conf中设置4194304
2. linux会设置40%的可用内存用来做系统cache，当flush数据时这40%内存中的数据由于和IO同步问题导致超时(120s)，所将40%减小到10%，避免超时。在文件/etc/sysctl.conf中加入 vm.dirty_ratio=10

