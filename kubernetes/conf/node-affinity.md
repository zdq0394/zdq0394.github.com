# Assigning Pods to Nodes
可以限制一个pod**只能**调度到某些nodes上运行；
也可以限制一个pod**优先**调度到某些nodes上运行。

## nodeSelector
**nodeSelector**是最简单的限制方法。
`nodeSelector`是PodSpec的一个字段。
指定了一个key-value pairs的映射。

此时，pod只能调度到那些拥有`nodeSelector`指定的label的节点上。