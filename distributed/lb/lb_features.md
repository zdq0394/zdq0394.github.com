# 负载均衡器特性
本文从整体上介绍负载均衡器提供的几个特性（features）。
并非所有的负载均衡器都会实现所有这些特性。

## 服务发现：Service discovery
服务发现（Service discovery）：负载均衡器确定可用backends的过程。 
负载均衡器的服务发现手段各种各样，包括：静态配置文件、DNS、Zookeeper、Etcd、Consul等

## 健康检查：Health checking
健康检查（Health checking）：负载均衡器确定一个backend是否可以承载服务流量的过程。
健康检查方式大体有两类：
* 主动式（Active）： 负载均衡器定期发心跳包。
* 被动式（Passive）： 负载均衡器通过数据流检测backend是否正常。比如对于L4，如果后端连续三次connection error可以认为backend不可用。对于L7，如果连续三次收到HTTP 503响应，可以认为backend不可用。

## 负载均衡：Load balancing
负载均衡器一定要能够均衡负载（废话）。
负载均衡器选择可用backend的策略很多：简单的如随机选择、round robin；复杂的如：考虑延迟、backend load等。

## Session粘性：Sticky sessions
对某些应用来说，同一个session的请求达到同一个backend非常重要。这或许和cache、临时复杂状态等相关。
Session一般包括：HTTP cookies，Client Connection的属性等。很多L7负载均衡器对sticky session都有一定的支持。

## TLS termination
多数L7负载均衡器对TLS处理做了大量工作：termination、证书验证和绑定，certificate serving using SNI等。

## 可观察性：Observability
网络本质上具有不可靠性。
负载均衡器需要能够汇报状态、traces和logs以帮助运维人员定位问题。
负载均衡器的输出各有不同：一般包括 numeric stats, distributed tracing, and customizable logging。

## Security and DoS mitigation
负载均衡器一般都实现了多种安全特性。
* 流量限制
* 认证
* DoS缓解（IP address tagging和标识）

## Configuration and control plane
负载均衡器需要是可配置的。
在大规模部署中，部署是一个大工程。
配置负载均衡器的system一般被称为控制平面（control plane）。