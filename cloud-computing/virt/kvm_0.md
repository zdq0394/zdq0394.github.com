# KVM概述
## KVM起源
KVM的全称是Kernel-based Virtual Machine。KVM虚拟机最初是由一个以色列的创业公司Qumranet开发的。为了简化开发，KVM的开发人员并没有选择从底层开始新写一个Hypervisor，而是选择了**基于Linux Kernel**，通过**加载新的模块**从而使Linux Kernel本身变成一个**Hypervisor**。

2006年10月，KVM模块的源代码呗正式接纳进入Linux Kernel，成为内核源代码的一部分。

2008年9月，Redhat收购了Qumranet并在自己的发行版中使用KVM替代Xen。KVM的核心组件从Linux2.6.20开始包含进主干。KVM的用户空间组件从1.3版本开始包含在QEMU主干中。





	