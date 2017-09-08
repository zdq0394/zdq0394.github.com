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

