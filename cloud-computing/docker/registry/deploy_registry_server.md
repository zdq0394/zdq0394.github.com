# 部署Registry服务
部署registry之前，需要先安装Docker Engine。因为Registry服务是以docker容器方式运行的。

## 运行一个本地Registry
运行一个本地测试用的Registry服务非常简单，[参见](overview.md)。

## 基本配置
运行docker run命令时，可以通过传递参数来配置registry服务的运行。

### 配置registry自启动
如果要将registry作为永久基础设施的一部分，需要将registry设置为自动启动，可以通过flag（**--restart**）设置。如下：

```
$ docker run -d \
  -p 5000:5000 \
  --restart=always \
  --name registry \
  registry:2
```

### 定制Registry服务端口
Registry服务默认运行在5000端口。可以通过**-p**进行定制。

```
-p HOST_PORT:container_port
```

如下将Registry服务发布到5001端口，容器名字为“registry-test”。

```
$ docker run -d \
  -p 5001:5000 \
  --name registry-test \
  registry:2
```

通过注入环境变量**REGISTRY_HTTP_ADDR=0.0.0.0:5001**，可以改变Registry容器的运行端口。

如下将容器运行在5001端口，并且发布到5001端口。

```
$ docker run -d \
  -e REGISTRY_HTTP_ADDR=0.0.0.0:5001 \
  -p 5001:5001 \
  --name registry-test \
  registry:2
```

## 存储配置
### 定制存储地址
Registry默认将数据（data）作为**docekr volume**持久化到宿主机文件系统中。也可以将registry data存储到宿主机文件系统的指定位置。下面的例子将宿主机的目录/mnt/registry绑定到容器/var/lib/registry/。

```
$ docker run -d \
  -p 5000:5000 \
  --restart=always \
  --name registry \
  -v /mnt/registry:/var/lib/registry \
  registry:2
```

### 定制后台存储机制
默认，registry将数据存储到本地文件系统，不论是volume还是bind mount宿主机目录。
通过配置可以将数据存储到Amazon S3 bucket、Google Cloud Platform或者其它的存储后端。

## 运行安全的registry
### 获取证书
本例假设：

* Registry可以在 https://myregistry.domain.com/ 访问。
* 你的DNS、路由和防火墙设置允许访问host的5000端口。
* 你已经从一个证书认证中心（CA）获取一个证书。

**1. 创建一个certs目录**

```
$ mkdir -p certs
```
将从CA获取的文件（.crt和.key）复制到certs目录。以下步骤假设文件命名为：domain.crt和domain.key。

**2. 停止registry，如果registry正在运行**

```
$ docker stop registry
```
**3. 重启registry，使用TLS certificate**
该命令将certs/目录bind-mounts到容器中的/certs/目录，并且同构设置环境变量告诉容器domain.crt和domain.key文件的地址。Registry服务运行在80端口。

```
$ docker run -d \
  --restart=always \
  --name registry \
  -v `pwd`/certs:/certs \
  -e REGISTRY_HTTP_ADDR=0.0.0.0:80 \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt \
  -e REGISTRY_HTTP_TLS_KEY=/certs/domain.key \
  -p 80:80 \
  registry:2
```
**4. Docker clients can now pull from and push to your registry using its external address**。

```
$ docker pull ubuntu:16.04
$ docker tag ubuntu:16.04 myregistrydomain.com/my-ubuntu
$ docker push myregistrydomain.com/my-ubuntu
$ docker pull myregistrydomain.com/my-ubuntu
```
**USE AN INTERMEDIATE CERTIFICATE**

证书签发机构可能仅提供一个**中间证书（intermediate certificate）**。在这种情况下，必须连接你的certificate和intermediate certificate生成一个certificate bundle。

```
cat domain.crt intermediate-certificates.pem > certs/domain.crt
```

## Run Registry as Swarm Service

## 负载均衡配置

## 访问控制配置

## 以Compose file部署Registry容器服务

## 隔离网络配置