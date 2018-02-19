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

## Docker作用
**Fast, consistent delivery of your applications**

Docker允许开发人员在本地标准化的容器中提供应用和服务，从而将开发生成周期stream化。容器非常适合持续集成和持续部署流程。

**Responsive deployment and scaling**

Docker基于容器的平台使得工作负载高度可移植。Docker容器可以运行在笔记本、物理机和虚拟机上，也可以运行在云端或者混合的环境中。

Docker移植便捷性和轻量使得它很容易动态的管理负载，根据业务需要近乎实时的扩容或者缩容。

**Running more workloads on the same hardware**

Docker是轻量并且迅速的。与基于hypervisor的虚拟机相比，它提供了一个切实可行的、成本节约的替代方案。在高密度环境中、小型或者中型的环境部署更多应用、使用更少资源方面，Docker是完美的。

## Docker architecture
Docker使用client-server架构。
Docker client和Docker daemon交互。Docker daemon构建、运行、分发容器。Docker client和docker daemon可以运行在同一个系统上。Docker client也可以连接远程的Docker daemon。Docker client和Docker daemon通过REST API交互，链路通过UNIX sockets或者网络接口。

![](pics/arch.svg)

### Docker Daemon
Docker daemon (dockerd)监听Docker API请求并管理Docker对象：镜像（images）、容器（containers）、网络（networks）和卷（volumes）。一个Docker daemon也可以和其它的daemon通信以管理Docker Services。

### Docker Client
Docker client (docker)大多Docker用户使用docker的主要方式。当你使用docker命令比如docker run时，client将命令发送dockerd。Docker client可以和多个daemon通信。

### Docker registries
Docker registry存储docker镜像。Docker Hub和Docker Cloud是公共registries。Docker默认从docker hub拉取镜像。 

### Docker Objects
当你使用docker时，你就会创建很多docker对象：images、containers、networks、volumes、plugins和其它对象。本节简要描述一下几个对象。
#### Images
镜像是一个只读的模版：包含了创建docker容器的命令。
通常的，一个镜像一般是基于另外一个镜像的构建的，然后做一些**定制化**的东西。
例如：你可以基于ubuntu构建一个镜像，然后安装Apache服务器和你自己的应用，以及一些应用运行需要的配置信息。

为了构建自己的镜像，你可以编写一个Dockerfile。Dockerfile定义了一个简答的语法，定义了构建镜像的几个步骤。
Dockerfile中的每个命令构成了镜像的一个层。
如果你改变了Dockerfile重新构建它，只有改变的层才会重新构建。这也是与其它虚拟化技术相比，docker轻便迅捷的原因之一。
#### Containers
容器是镜像的一个运行实例。
可以通过Docker CLI或者API创建、启动、停止、移动、删除一个容器。
可以将容器连接到一个或者多个网络上。
可以挂在存储到容器上。
可以基于容器当前的状态创建一个新的镜像。

默认情况下，一个容器和其它的容器以及宿主机相对隔离。
可以控制网络、存储以及其它底层系统的隔离程度。

一个容器由镜像和启动时的配置选项定义。当删除容器时，所有没有写入持久化存储的状态都将丢失。
#### Services
Services allow you to scale containers across multiple Docker daemons, which all work together as a swarm with multiple managers and workers. Each member of a swarm is a Docker daemon, and the daemons all communicate using the Docker API. A service allows you to define the desired state, such as the number of replicas of the service that must be available at any given time. By default, the service is load-balanced across all worker nodes. To the consumer, the Docker service appears to be a single application. Docker Engine supports swarm mode in Docker 1.12 and higher.
## 底层技术
### Namespaces
Docker使用namespaces为容器运行提供隔离的工作空间。创建一个容器时，Docker会为容器创建一系列的namespaces。
Namespace提供了一层隔离。容器的每个方面都运行在一个独立的namespace中，容器的每个方面也都被限定在那个namespace中。

Docker Engine使用下列namespaces：
* The pid namespace: Process isolation (PID: Process ID).
* The net namespace: Managing network interfaces (NET: Networking).
* The ipc namespace: Managing access to IPC resources (IPC: InterProcess Communication).
* The mnt namespace: Managing filesystem mount points (MNT: Mount).
* The uts namespace: Isolating kernel and version identifiers. (UTS: Unix Timesharing System).
### Control groups
Docker Engine还依赖于control groups (cgroups)。
一个cgroup将应用限定在一组资源上。
Control groups允许Docker Engine共享可用的硬件资源，并（可选的）限定资源。比如，你可以限制某个容器的内存使用量。
### Union file systems
Union file systems, or UnionFS, are file systems that operate by creating layers, making them very lightweight and fast. Docker Engine uses UnionFS to provide the building blocks for containers. Docker Engine can use multiple UnionFS variants, including **AUFS**, **btrfs**, **vfs**, and **DeviceMapper**。
### Contaier format
Docker Engine combines the namespaces, control groups, and UnionFS into a wrapper called a **container format**. 
The default container format is **libcontainer**. 
In the future, Docker may support other container formats by integrating with technologies such as BSD Jails or Solaris Zones.