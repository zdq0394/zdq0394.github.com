# 自动加载内核模块
在`/etc/sysconfig/modules/`增加一个可执行文件，加载某个某块。
(1) `ipvs.modules`
```sh
#!/bin/bash
modprobe -- ip_vs
modprobe -- ip_vs_sh
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- nf_conntrack_ipv4
```
