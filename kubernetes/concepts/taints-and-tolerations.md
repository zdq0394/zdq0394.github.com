# Taints and Tolerations
Node affinity是pod的一个属性，可以**吸引**pod调度到某些nodes上面，这种吸引可以是硬性要求，也可以是偏好要求。

Taints正好相反，它可以使得一个node**排斥**一些pods。

**Taints and Tolerations**联合确保pods不会调度到不合适的nodes上面。

一个node可以包含一个或者多个**taints**，这表示如果pods不能tolerate这些**taints**，就不会调度到这个node上面；
**Tolerations**是node的属性，允许（不是必需）pods可以调度到拥有匹配taints的nodes上面。


## Example Use Cases
* Dedicated Nodes： 设置一些节点只能给指定用户的pods使用。结合nodeaffinity使用。
* Nodes with Special Hardware： 



## Taints based Evictions
`NoExecute`影响节点上已经运行的pods。

当给一个node添加一个effect为`NoExecute`的taint时，将影响该node上所有的pods：
* 如果pod没有tolerate相应的taint，将会被立即evicted。
* 如果pod可以tolerate相应的taint，并且没有指明tolerationSeconds，pod可一直运行下去。
* 如果pod可以tolerate相应的taint，但是指定了tolerationSeconds，那么pod可以运行指定的时间，然后才被evicted。


