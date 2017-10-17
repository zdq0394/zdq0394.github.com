# KVM CPU虚拟化

## VMCS
对于虚拟化的VT技术而言，它的软件部分基本体现在vmcs结构中（virtual machine control block)。主要通过vmcs结构来控制vcpu的运转。

* vmcs是个不超过4K的内存块
* vmcs通过下列的指令控制：vmclear:清空vmcs结构，vmread:读取vmcs数据，vmwrite:数据写入vmcs
* 通过VMPTR指针指向vmcs结构，该指针包含vmcs的物理地址。

VMCS包含的信息可以分为以下六个部分：

* Guest State Area:虚拟机状态域，保存**非根模式的vcpu运行状态**。当VM-Exit发生，vcpu的运行状态要写入这个区域，当VM-Entry发生时，cpu会把这个区域保存的信息加载到自身，从而进入非根模式。这个过程是硬件自动完成的。保存是自动的，加载也是自动的，软件只需要修改这个区域的信息就可以控制cpu的运转。
* Host state area：宿主机状态域，保存**根模式下cpu的运行状态**。只在vm-exit时需要将状态恢复，在vm-entry时却不需要保存，因为宿主机的状态一般是不需改变的。
* VM-Execution control filelds：包括page fault控制，I/O位图地址，CR3目标控制，异常位图，pin-based运行控制（异步事件），processor-based运行控制（同步事件）。**这个域可以设置哪些指令触发VM-Exit**。触发VM-Exit的指令分为无条件指令和有条件指令，这里设置的是有条件指令。
* VM-Entry contorl filelds：包括vm-entry控制，vm-entry MSR控制，VM-Entry插入的事件。MSR是cpu的模式寄存器，设置cpu的工作环境和标识cpu的工作状态。
* VM-Exit control filelds：包括VM-Exit控制，VM-Exit MSR控制。
* VM退出信息：这个域保存VM-Exit退出时的信息，并且描述原因。

有了vmcs结构后，对虚拟机的控制就是读写vmcs结构。对vcpu设置中断，检查状态实际上都是在读写vmcs结构。