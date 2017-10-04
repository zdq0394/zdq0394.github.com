# Registry功能
Registry是一个**存储系统**也是一个**内容分发系统**：保存命名的docker images，每个image拥有一个不同的tag版本。
用户可以使用docker push和pull命令与registry交互。

```
docker pull registry-1.docker.io/distribution/registry:2.1
```
Registry的存储通过不同的drivers由不同的实现。默认的存储driver是本地posix文件系统，非常适合开发和小型部署。Registry也支持云存储：比如S3、Microsoft Azure、OpenStack Swift和Aliyun OSS。也可以实现Storage API开发自己的driver，接入自己的存储。

Registry原生支持TLS和basic认证。

GitHub上的Registry包括更高级的认证和授权方式。只有非常大的公共部署需要按照这种方式扩展Registry。

最终，Registry提供了一个容错性强的通知系统（notification system），调用webhooks。这些webhooks针对registry动作，日志和汇报。

## 理解镜像的命名
典型的docker命令中使用的镜像名字反映了镜像的来源：

* **docker pull ubuntu**指令docker从官方的Docker Hub中拉取名字为ubuntu的镜像。这是一个简写，全称形式如下：**docker pull docker.io/library/ubuntu**。
* **docker pull myregistrydomain:port/foo/bar**指令docker从**myregistrydomain:port**查找镜像**foo/bar**。

## 使用案例
* 运行自己的Registry与CI/CD系统集成并完善CI/CD系统是一个很好的解决方案。在一个典型的工作流程中，一次对版本控制系统（比如github）的提交（commit）会触发CI系统的一次构建，如果构建成功，会推送一个新的image到registry。此时，registry会通过notification触发一次到staging系统的部署，或者通知其它系统：一个新的镜像可用了。
* 如果要在大规模集群中部署一个新的镜像，Registry也是一个核心的组件。
* Registry也是在一个隔离的网络中分发镜像的最好方式。

## Requirements
* 必须非常熟悉Docker，尤其时pushing和pulling镜像。
* 必需理解daemon和cli的不同，至少理解网络的基本概念。