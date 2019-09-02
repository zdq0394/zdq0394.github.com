# Calico
## 概述
Calico是一个纯三层的数据中心网络方案（不需要Overlay）。
Calico在每一个计算节点利用Linux Kernel实现了一个高效的vRouter来负责数据转发。
而每个vRouter通过BGP协议把自己节点上运行的workload的路由信息向整个Calico网络内传播，最终所有的workload之间的数据流量都是通过IP路由的方式完成互联的。

Calico节点组网可以直接利用数据中心的网络结构（无论是L2或者L3），不需要额外的NAT，隧道或者Overlay Network。

Calico网络示例：
![](pics/calico-flow.png)

## 术语
* 宿主机：宿主节点，也可以称为计算节点，提供workload endpoints——比如vm/containers。
* Workload Endpoints：宿主机上运行的工作负载：比如vm/containers。


## 组件
* Felix
* BIRD
* BGP Route Reflector
* etcd
* Orchestrator Plugin

### Felix
Felix是一个守护程序，它在每个提供endpoints资源的计算机上运行。在大多数情况下，这意味着它需要在托管容器或VM的宿主机节点上运行。 Felix负责编制路由和ACL规则以及在该主机上所需的任何其他内容，以便为该主机上的endpoints资源正常运行提供所需的网络连接。

根据特定的编排环境，Felix负责以下任务：
* 管理网络接口，Felix将有关接口的一些信息编程到内核中，以使内核能够正确处理该endpoint发出的流量。特别是，它将确保主机正确响应来自每个工作负载的ARP请求，并将为其管理的接口启用IP转发支持。它还监视网络接口的出现和消失，以便确保针对这些接口的编程得到了正确的应用。
* 编写路由，Felix负责将到其主机上endpoints的路由编写到Linux内核FIB（转发信息库）中。 这可以确保那些发往目标主机的endpoints的数据包被正确地转发。
* 编写ACLs，Felix还负责将ACLs编程到Linux内核中。这些ACLs用于确保只能在endpoints之间发送有效的网络流量，并确保endpoints无法绕过Calico的安全措施。
* 报告状态，Felix负责提供有关网络健康状况的数据。特别是，它将报告配置其主机时发生的错误和问题。该数据会被写入etcd，以使其对网络中的其他组件和操作可见。

### BIRD
Calico在每个运行Felix服务的节点上都部署一个BGP客户端。BGP客户端的作用是读取Felix程序编写到内核中的路由信息，并在数据中心内分发这些路由信息。

BGP客户端负责执行以下任务：

* 路由信息分发，当Felix将路由插入Linux内核FIB时，BIRD将接收它们并将它们分发到集群中的其他工作节点。

### BGP Route Reflector
A BGP client configured as a reflector。
* centralized route distribution

### etcd
etcd is a distributed key-value store that has a focus on consistency. 
Calico uses etcd to provide the communication between components and as a consistent data store, which ensures Calico can always build an accurate network.
* data storage：etcd stores the data for the Calico network in a distributed, consistent, fault-tolerant manner (for cluster sizes of at least three etcd nodes). 
* communication: etcd is also used as a communication bus between components.

## 技术原理
1. responding to workload ARP requests with the host MAC
2. IP routing tables: for connectivity
3. iptables: for isolation

In a Calico network, each compute server acts as a **router** for all of the endpoints that are hosted on that compute server.

## 参考信息
* https://www.kubernetes.org.cn/4960.html