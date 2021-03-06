# 概述
## Registry是什么
* Registry是一个**无状态**的**高可扩展**的服务端应用。
* Registry能够存储镜像并允许分发镜像。
* Registry是开源的。

## 为什么使用Registry
使用Registry可以：
* 紧密的控制镜像的存储
* 全面控制镜像的分发流水线
* 将镜像的存储和分发与已经存在的开发工作流程集成

## Requirements
Registry与Docker engine版本1.6.0+兼容。

## 简单示例
启动Registry

``` sh
docker run -d -p 5000:5000 --name registry registry:2
```

从Docker Hub Pull(或者build)一个镜像

```sh
docker pull ubuntu
```

给镜像打个新的tag，指向自己的registry

```sh
docker tag ubuntu localhost:5000/myfirstimage
```

推送镜像

```sh
docker push localhost:5000/myfirstimage
```

拉回镜像

```sh
docker pull localhost:5000/myfirstimage
```

停止registry，并清除所有数据

``` sh 
docker stop registry && docker rm -v registry
```

