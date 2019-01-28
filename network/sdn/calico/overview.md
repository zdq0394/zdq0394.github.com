# Calico
## 概述
Calico是一个纯三层的数据中心网络方案（不需要Overlay）。
Calico在每一个计算节点利用Linux Kernel实现了一个高效的vRouter来负责数据转发。
而每个vRouter通过BGP协议把自己节点上运行的workload的路由信息向整个Calico网络内传播，最终所有的workload之间的数据流量都是通过IP路由的方式完成互联的。

Calico节点组网可以直接利用数据中心的网络结构（无论是L2或者L3），不需要额外的NAT，隧道或者Overlay Network。

Calico网络示例：
![](pics/calico-flow.png)

## 组件
* Felix
* BIRD
* BGP Route Reflector
* etcd
* Orchestrator Plugin

### Felix
* interface management
* route programming
* acl programming
* state reporting

### BIRD
It is a BGP client: read routing state that Felix programs into the Kernel and distribute it around the data centre.

* route distribution

### BGP Route Reflector
A BGP client configured as a reflector
* centralized route distribution

### etcd
etcd is a distributed key-value store that has a focus on consistency. 
Calico uses etcd to provide the communication between components and as a consistent data store, which ensures Calico can always build an accurate network.
* data storage
* communication: etcd is also used as a communication bus between components.

## 技术原理
1. responding to workload ARP requests with the host MAC
2. IP routing tables: for connectivity
3. iptables: for isolation
