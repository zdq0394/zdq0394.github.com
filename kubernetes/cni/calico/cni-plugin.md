# CNI Plugin
## 概述
Calico的CNI Plugin由两个静态的二进制文件组成，由kubelet以命令行的形式调用。
* calico-ipam：分配维护IP，依赖etcd。
* calico：系统调用API来修改namespace中的网卡信息。