# Filesystem Bundle
## Container Format
Filesystem bundle：按照某种方式组织的文件集合。该文件集合包含了一切必须的数据和元数据，可以由OCI兼容的运行时针对该文件集合进行标准的操作。

Container Format定义了如何把容器编码为filesystem bundle。

Bundle的定义：容器及其配置数据如何存储在本地文件系统，进而可以由容器运行时操作。

一个标准的容器包含了加载和运行该容器所有必要的信息：
* config.json: 包含配置数据；必须包含在bundle目录的根下；必须命名为config.json。
* container's root filesystem：被config.json中变量root.path引用的root filesystem。

两者不必在本地文件系统的同一个目录下，目录本身不属于bundle。config.json的父文件夹不属于bundle。

