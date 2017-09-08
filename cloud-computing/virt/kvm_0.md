# KVM概述
## KVM
KVM的全称是Kernel Virtual Machine。KVM虚拟机最初是由一个以色列的创业公司Qumranet开发的。为了简化开发，KVM的开发人员并没有选择从底层开始新写一个Hypervisor，而是选择了**基于Linux Kernel**，通过**加载新的模块**从而使Linux Kernel本身变成一个**Hypervisor**。

2006年10月，KVM模块的源代码呗正式接纳进入Linux Kernel，成为内核源代码的一部分。

2008年9月，Redhat收购了Qumranet并在自己的发行版中使用KVM替代Xen。

KVM是基于**硬件虚拟化扩展**（Intel VT或者AMD-V）技术，是**Linux完全原生**的**全虚拟化**解决方案。

KVM包含一个可加载的Kernel module: kvm.ko和一个处理器相关的module：kvm-intel.ko or kvm-amd.ko。

KVM是开源软件。KVM的核心组件从Linux2.6.20开始包含进主干。KVM的用户空间组件从1.3版本开始包含在QEMU主干中。

KVM仅支持硬件虚拟化。打开并初始化系统硬件以支持虚拟机的运行，是KVM模块的职责所在。

在被内载加载的时候，KVM模块会先初始化内部的数据结构；做好准备之后，KVM模块检测系统当前的CPU，然后打开CPU控制寄存器CR4中的虚拟化模式开关；通过执行VMXON指令将宿主操作系统（包括KVM模块本身）置于虚拟化模式中的根模式；最后，KVM模块创建特殊设备文件/dev/kvm并等待来自用户空间的命令（QEMU）。

虚拟机的创建和运行将是一个用户空间的应用程序QEMU和KVM模块相互配合的过程。

在KVM架构中，虚拟机实现为常规的Linux进程，由标准的Linux调度程序进行调度。事实上，每个虚拟CPU显示为一个常规的Linux线程。

KVM本身不执行任何模拟，需要用户空间应用程序(QEMU)通过/dev/kvm接口设置一个客户机虚拟服务器的地址空间，向它提供模拟的I/O，并将它的视频显示映射回宿主的显示屏。




	