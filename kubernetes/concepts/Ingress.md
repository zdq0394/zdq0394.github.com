# Ingress
## 为什么使用Ingress
* 虽然LoadBalancer Service也可以使得服务对外，但是每个LoadBalancer service都需要一个它自己的load balancer，这个load balancer拥有独立的public IP地址；而Ingress只需要一个，就可以提供对多个services对外服务。
* Service不是工作在应用层，比如不能针对HTTP应用做些特殊的处理（不能提供7层负载均衡）；而Ingress可以。
## Ingress

## Ingress Controller


