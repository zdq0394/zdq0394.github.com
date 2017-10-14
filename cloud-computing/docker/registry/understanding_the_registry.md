# Registry功能
Registry是一个**存储系统**也是一个**内容分发系统**：保存大量的docker images，每个image都拥有一个不同的tag。
例如repository**distribution/registry**，拥有两个tag：2.0和2.1。

用户可以使用docker push和docker pull命令与registry进行交互。

```
docker pull registry-1.docker.io/distribution/registry:2.1
```
Registry的存储有多种，借助不同的drivers对接不同的存储后台。默认存储driver是本地posix文件系统，非常适合开发环境和小型环境。Registry也支持**云存储**：比如S3、Microsoft Azure、OpenStack Swift和Aliyun OSS等等。当然，也可以通过实现Storage API开发自己的driver，接入自己的存储。

安全访问是最重要的。Registry原生地支持TLS和basic认证。
GitHub上的Registry包括更高级的认证和授权方式。只有非常大的公共部署需要按照这种方式扩展Registry。

最后，Registry提供了一个容错性很强的通知系统（notification system）， calling webhooks in response to activity, and both extensive logging and reporting, mostly useful for large installations that want to collect metrics.

## 理解镜像的命名
docker命令中使用的镜像名字反映了镜像的来源：

* **docker pull ubuntu**指令docker从官方的Docker Hub中拉取名字为ubuntu的latest镜像。这是一个简写，全称形式如下：**docker pull docker.io/library/ubuntu**。
* **docker pull myregistrydomain:port/foo/bar**指令docker从**myregistrydomain:port**查找镜像**foo/bar**。

## 使用案例
* 私有Registry集成并完善CI/CD系统是一个很好的解决方案。在一个典型的工作流程中，一次对版本控制系统（比如github）的提交（commit）会触发CI系统的一次构建，如果构建成功，会推送一个新的image到registry。此时，registry会通过notification触发一次到staging系统的部署，或者通知其它系统**一个新的镜像可用了**。
* 私有Registry也是大规模部署docker镜像的一个核心组件。
* 私有Registry也是在一个隔离的网络中分发镜像的最好方式。

## Requirements
* 必须非常熟悉Docker，尤其时pushing和pulling镜像。
* 必需理解daemon和cli的不同，至少理解网络的基本概念。