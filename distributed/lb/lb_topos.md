# 负载均衡器的部署拓扑
## Middle proxy
![](pics/lb4.png)
Figure 4: Middle proxy load balancing topology

图4所示的部署方式：middle proxy是最常见的。
* 硬件方案：Cisco, Juniper, F5等
* 云部署方案：Amazon的ALB和NLB，Google的云负载均衡器（Cloud Load Balancer)
* 软件部署方案：HAProxy和NGINX等。

* 优势：对用户简单。用户通过DNS连接到负载均衡器即可，不需要关心其它的。
* 劣势：proxy是个单点；扩展瓶颈；黑盒子，难以定位问题：不知道是客户端、物理链路还是proxy或者backend的问题。 

## Edge proxy
![](pics/lb5.png)
Figure 5: Edge proxy load balancing topology

**Edge proxy**是**middle proxy**的一个变种：负载均衡器可以通过internet访问。
在该场景下，负载均衡器另外提供API gateway以支持TLS termination, rate limiting, authentication等流量路由技术。
Edge Proxy的优势和劣势与middle proxy相同。

## Embedded client library
![](pics/lb6.png)
Figure 6: Load balancing via embedded client library

**Middle proxy**具有单点故障和扩展性问题，为了避免这两个问题，可以把负载均衡功能作为一个library嵌入到客户端程序中，如图6所示。
* 优势：把负载均衡功能嵌入到各个客户端中，消除了单点故障和扩展问题。
* 劣势：负载均衡功能的library必须通过每个编程语言实现一次；潜在的升级问题。

## Sidecar proxy
![](pics/lb7.png)
Figure 7: Load balancing via sidecar proxy

**Sidecar proxy**是**client library**模式的一个变种。
近年来，这种部署方式以**service mesh**流行起来。
背后的思想是：通过转嫁到一个不同的流程，牺牲轻微的延迟，以获取**client library**模式的所有优势，并且消除了编程语言锁定。
比较流行的sidecar proxy包括：NGINX，HAPROXY和Linkerd。

## Summary and pros/cons of the different load balancer topologies
* **middle proxy**最典型易用，但是存在单点故障和扩展性限制，以及黑盒操作。
* **edge proxy**和**middle proxy**类似，但是无法避免。
* **embedded client library topology**提供了好的性能和扩展性，但是需要各种语言实现，并存在升级问题。
* **sidecar proxy** 避免了**client library**的缺点，但是存在轻微的性能损失。

综合来看，sidecar proxy（service mesh）将逐渐在service-to-servcie communication中代替其它的部署方式；而**edge proxy**部署在service mesh之前，对流量进行一层均衡和过滤。