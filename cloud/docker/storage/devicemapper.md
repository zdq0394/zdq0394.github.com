# devicemapper
## Device Mapper简介
[Device Mapper](../../../linux/devicemapper.md)是Linux系统中基于内核的**高级卷管理技术框架**。
它是内核中支持逻辑卷管理的**通用设备映射机制**，为实现**块设备驱动**提供了一个高度模块化的内核架构，包含三个重要的对象概念：Mapped Device、Mapping Table、Target device。
Docker的**devicemapper**存储驱动基于该框架的**thin-provisioning**和**snapshotting**功能来实现对镜像和容器的管理。

* Device Mapper： Linux Kernel Framework
* devicemapper： Docker Storage Driver

Docker Engine的**devicemapper存储驱动**使用专用**块设备**来存储数据而非文件系统。块设备可以通过增加物理磁盘扩展，比通过操作系统在文件层面性能更好。


## How the `devicemapper` storage driver works

