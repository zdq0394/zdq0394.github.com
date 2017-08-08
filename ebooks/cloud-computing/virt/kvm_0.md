# KVM概述


KVM (for Kernel-based Virtual Machine)是一种X86架构上的基于Linux的全虚拟化方案，需要硬件虚拟化支持(Intel VT or AMD-V)。


KVM包含一个可加载的Kernel module: kvm.ko和一个处理器相关的module：kvm-intel.ko or kvm-amd.ko。


使用KVM，可以运行多个未见修改的Linux或者Windows虚拟机。每个虚拟机都拥有独立的虚拟设备：网卡、磁盘、显卡等。


KVM是开源软件。KVM的核心组件从Linux2.6.20开始包含进主干。KVM的用户空间组件从1.3版本开始包含在QEMU主干中。