# 标准容器
## 标准容器的原则
标准容器：把软件及其依赖包封装成一定的格式`format`，使其能够自描述和可移植。从而使得OCI兼容的runtime不需要额外信息即可运行它，不论底层的操作系统/机器架构以及容器的内容。

标准容器规范定义了以下3点：
* 配置文件（configuration）格式
* 标准操作集合
* 执行环境

### 标准容操作
**Standard Containers**定义了一系列**STANDARD OPERATIONS**。

容器可以：
* 通过标准容器工具创建、启动、停止；
* 通过标准文件系统工具复制和snapshot。
* 通过标准网络工具下载和上传。

### Content-agnostic（内容中立、内容无关）
**Standard Containers**是内容中立内容无关大的。无论内容如何，标准操作的作用都是一样的。

### Infrastructure-agnostic（基础设施中立）
**Standard Containers**是基础设施中立的。
可以运行在任何支持OCI的基础设施上。

### Designed for automation
**Standard Containers**从设计上就针对为自动化的。不管基础设施、也不管内容如何，容器都提供同一的标准操作。
标准容器非常适合自动化，甚至可以说自动化是它们的秘密武器。

很多过去人工操作的事情——非常耗时并且容易出错的事情，现在可以编程实现。

### Industrial-grade delivery
**Standard Containers**让软件的企业级分发成为现实。

## Filesystem Bundle
### Container Format
Filesystem bundle：按照某种方式组织的文件集合。该文件集合包含了一切必须的数据和元数据，可以由OCI兼容的运行时针对该文件集合进行标准的操作。

Container Format定义了如何把容器编码为filesystem bundle。

Bundle的定义：容器及其配置数据如何存储在本地文件系统，进而可以由容器运行时操作。

一个标准的容器包含了加载和运行该容器所有必要的信息：
* config.json: 包含配置数据；必须包含在bundle目录的根下；必须命名为config.json。
* container's root filesystem：被config.json中变量root.path引用的root filesystem。

两者必须在本地文件系统的同一个目录下，目录本身不属于bundle。换句话说，一个bundle的tar包，必须把这些包含在archive的root中，而不是嵌入在一个top-level的文件夹中。

## Runtime和Lifecycle
### State
* ociVersion
* id
* status
    * creating
    * created
    * running
    * stopped
* pid：从主机上看到的container的process ID。
* bundle： 指向bundle directoy的绝对目录。这样运行时可以找到容器的配置数据和root filesystem。
* annotations: 容器的附加数据。
```json
{
    "ociVersion": "0.2.0",
    "id": "oci-container1",
    "status": "running",
    "pid": 4422,
    "bundle": "/containers/redis",
    "annotations": {
        "myKey": "myValue"
    }
}
```
### Lifecycle
容器从创建到退出的整个timeline。
1. OCI Runtime的create命令被调用，并且接受2个参数：
    * 指向bundle的reference
    * 唯一ID
2. 容器的运行时“环境变量”被创建——根据config.json。如果创建失败，产生ERROR。该阶段不会运行user-specified的程序。该步骤之后，对config.json进行的更新不会影响容器。
3. OCI Runtime的start命令被调用，并且接受参数：container ID。
4. OCI Runtime调用prestart hooks。如果prestart hooks调用失败，则产生ERROR，并且stop container，然后进行step 9。
5. OCI Runtime运行user-specified的程序。
6. OCI Runtime调用poststart hooks。如果某个poststart hook调用失败，运行时记录Warning日志，但是后续操作继续进行。
7. 容器的进程退出——erroring、exiting或者crashing或者容器的kill命令被调用。
8. OCI Runtime的delete命令被调用，接受参数：container ID。
9. 容器被destroy。
10. OCI Runtime调用poststop hooks。如果某个poststop hook失败，运行时记录Warning日志，但是剩下的hooks会继续进行。

### Errors
发生error要终止操作，并回滚状态。
### Warning
记录warning日志不改变操作流程，操作继续进行，就像warning从没有发生过。

### 操作
* query state： state <container-id>
* create： create <container-id> <path-to-bundle>
* start： start <container-id>
* kill： kill <container-id> <signal>
* delete： delete <container-id>