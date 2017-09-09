# KVM环境构建
## 硬件系统的配置
在x86-64架构的处理器中，KVM必需的硬件虚拟化扩展分别为：Intel的虚拟化技术（Intel VT）和ADM的AMD-V技术。

1. 处理器（CPU）硬件上支持VT技术
2. BIOS中将CPU虚拟化功能打开

在Linux系统中，可以通过如下命令查看CPU是否支持硬件虚拟化：

``` sh 
# grep -E `(vmx|svm)` /proc/cpuinfo
```

## 配置KVM

通常Linux比较新的发行版（2.6.20+）都包含了KVM内核模块。
检查是否加载了kvm和kvm_intel模块，如果没有加载可以通过modprobe命令加载。

```sh
# lsmod | grep kvm
# modprobe kvm
# modprobe kvm_intel
```

确认KVM相关的模块加载成功后，检查/dev/kvm这个文件：

```sh 
# ls -l /dev/kvm
```

## 编译和安装qemu
执行如下命令下载qemu源代码和编译

```sh
# git clone git://git.qemu.org/qemu.git
# ./configure --enable-kvm --target-list=x86_64-softmmu --enable-debug
# make
```
configure时，选项较多，至少要指定**--enable-kvm**使得qemu利用kvm进行加速。一般还要**--enable-rbd**以支持ceph块存储。

## 安装libvirt

