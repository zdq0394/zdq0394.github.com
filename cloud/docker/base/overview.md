# Docker概述
Docker是一个开放平台，可以用来开发、分发和运行application。
Docker将基础设施和应用隔离，这样软件的分发速度极为迅速。
通过Docker，可以像管理应用一样管理基础设施。
利用Docker分发、测试和部署的优势，可以极大的减少编写代码和生产部署之间的延迟。
## Docker平台
Docker可以将应用的打包和运行分别在相对松散隔离的环境中：容器。
这种隔离和安全机制可以让你在一台主机上同时运行多个容器。
Containers是轻量级的，因为它们并不需要额外的hypervisor，而是直接运行在宿主机的kernel中。
这意味着与虚拟机相比，可以在一台宿主机上运行更多的容器。甚至你可以在虚拟机中运行容器。

Docker提供了容器的生命周期管理的工具和平台：
* 使用容器开发应用及其依赖组件。
* 容器成为分发和测试应用的基本单元。
* 合适的时候，将应用以容器或者编码服务的形式部署到生成环境。不管你的生产环境是本地数据中心还是云端或者混合云，部署方式都是一样的。

## Docker Engine
Docker Engine是一个CS架构的应用，包括一下几个组件：
* 一个长期运行的服务器： docker daemon。
* REST API： 提供与Docker Daemon交互的接口。
* Docker CLI。

![](pics/engine.png)

Docker CLI使用Docker REST API和Docker daemon交互，以脚本或者命令行的形式。很多Docker应用使用CLI或者这个底层的API。

Docker daemon创建和管理Docker对象：比如镜像、容器、网络和卷。
