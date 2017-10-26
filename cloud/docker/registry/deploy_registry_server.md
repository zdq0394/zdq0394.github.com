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
如果Registry运行在公网上，需要配置TLS。
### 获取证书
本例假设：
* Registry可以在 https://myregistry.domain.com/ 访问。
* DNS、路由和防火墙设置允许访问host的5000端口。
* 已经从一个**证书认证中心**（CA）获取一个证书。

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
该命令将certs/目录bind-mounts到容器中的/certs/目录，并且同时设置环境变量告诉容器domain.crt和domain.key文件的地址。Registry服务运行在80端口。

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
**4. Docker客户端现在可以使用这个外部地址使用pull/push镜像到这个registry**。

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
**Swarm services**比**standalone containers**提供了好几个优点。
Swarm services使用声明式模型：只要定义你期望的状态，docker保持你的服务达到期望的状态。
服务提供自动负载均衡扩展和服务分发能力。服务准许你在secrets中存储敏感数据（TLS certificates）。

存储后端的使用取决于你是使用一个fully-scaled的服务还是一个单节点的服务。

* 如果你使用一个分布式存储driver，比如Amazon S3，你可以使用一个完全多副本的服务。每个woker节点都可以同时写数据而不发生冲突。
* 如果你使用一个本地volume，每个worker节点将把数据写到自己的存储空间里，每个registry存储一个不同的数据集。 
## 负载均衡配置
你可能想用一个负载均衡器分担负载，终止TLS或者提供高可用。如何建立全面的负载均衡不是本文讨论的重点，但是有些注意点可以使setup过程更顺畅。

其中最最重要的一点就是Registries的负载均衡集群一定要共享资源：

* Storage Driver
* HTTP Secret
* Redis Cache (如果配置了的话)

### Important/Required HTTP-Headers
保证HTTP Headers正确非常重要。对任何/v2/空间下的url请求，响应中首部**Docker-Distribution-API-Version**应该都设置**registry/2.0**，哪怕是4xx响应。该首部可以使docker engine迅速处理**authentication realms**，如果必要的话，回到v1 registries。 确保这些设置正确可以避免fallback问题。

在同样的思想指导下，必须确保向“client-side”发送正确的X-Forwarded-Proto、X-Forwarded-For、and Host首部。否则会使registry重定向到内部的hostnames或者从https降级到http。

当一个/v2/端点被请求时，如果没有携带**凭据**，安全的registry应该返回**401**。响应中要包含**challenge**首部** WWW-Authenticate**：提供认证的方式（basic auth或者token服务）。

如果负载均衡器配置了健康检查，401响应应该配置为healthy，其它响应设置为down。

## 访问控制配置
除非registries运行在安全本地网络，否则registries应该总是实现访问控制。
### Native basic auth
实现访问限制的最简单的方式是使用basic authentication。

下面的例子通过htpasswd存储secrets，实现了basic authentication：

** 1. 创建一个password文件，包含一个条目testuser，密码是testpassword**
```
$ mkdir auth
$ docker run \
  --entrypoint htpasswd \
  registry:2 -Bbn testuser testpassword > auth/htpasswd
```
** 2. stop the registry**
```
$ docker stop registry
```

** 3. 以basic authentication方式启动registry**
```
$ docker run -d \
  -p 5000:5000 \
  --restart=always \
  --name registry \
  -v `pwd`/auth:/auth \
  -e "REGISTRY_AUTH=htpasswd" \
  -e "REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm" \
  -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd \
  -v `pwd`/certs:/certs \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt \
  -e REGISTRY_HTTP_TLS_KEY=/certs/domain.key \
  registry:2
```

** 4. 尝试从registry拉取镜像后者向registry推送镜像，命令应该会失败**

** 5. 登录registry，再次尝试第4步中的操作**
```
$ docker login myregistrydomain.com:5000

```

### More advanced authentication
Registry支持**委托认证**：将认证请求重定向到特殊的、受registry信任的token服务器。

这种方式更复杂，需要自己实现**认证服务**、**授权服务**和**token签发服务**。
## 以Compose file部署Registry容器服务
```
registry:
  restart: always
  image: registry:2
  ports:
    - 5000:5000
  environment:
    REGISTRY_HTTP_TLS_CERTIFICATE: /certs/domain.crt
    REGISTRY_HTTP_TLS_KEY: /certs/domain.key
    REGISTRY_AUTH: htpasswd
    REGISTRY_AUTH_HTPASSWD_PATH: /auth/htpasswd
    REGISTRY_AUTH_HTPASSWD_REALM: Registry Realm
  volumes:
    - /path/data:/var/lib/registry
    - /path/certs:/certs
    - /path/auth:/auth
```
可以将以上yaml作为模板，修改/path地址替换为自己的，然后用下面的命令启动：
```
$ docker-compose up -d
```
