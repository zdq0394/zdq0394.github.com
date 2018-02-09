# Kubernetes API概述
**REST API**是Kubernetes API的基础构造（fabric）。
所有的操作以及组件之间的交互，包括外部用户的命令都是由API Server处理的REST API请求。
如此，Kubernetes平台的所有的对象都是API Objects。

Kubernetes的大部分操作可以通过`kubectl`命令行执行，或者其它的命令行工具比如`kubeadm`。
也可以直接进行REST API调用。

## API Version
* Alpha: v1alpha1
* Beta: v2beta3
* Stable: vX，X是个整数

## API Groups
REST API路径指定了API Group；
API Object序列化后的apiVersion字段也指定了API Group。
* Core API Group：也称为遗留API Group。路径是`/api/v1`；apiVersion：`v1`
* Named Group：路径是`/apis/$GROUP_NAME/$VERSIOIN` apiVersion：`$GROUP_NMAE/$VERSION`；比如/apis/batch/v1（apiVersion: batch/v1）

## Enable API Groups
部分API Groups是默认enabled。
可以在启动API Server时，通过flag `--runtime-config`来决定是否开启某个API Group。
* disable batch/v1 --runtime-config=batch/v1=false
* enable batch/v2alpha1 --runtime-config=batch/v2alpha1

## Enable resources in the API Groups
下面这些资源是默认enable的：
* DaemonSets
* Deployments
* HorizontalPodAutoscalers
* Ingress
* Jobs
* ReplicaSets
可以在启动API Server时，通过flag `--runtime-config`来决定是否开启某个Resource。
--runtime-config=extensions/v1beta1/deployments=false,extensions/v1beta1/jobs=false


