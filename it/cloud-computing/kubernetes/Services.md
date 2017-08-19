# Services
Kubernetes Pods不是持久的（are mortal），并且无法被恢复。虽然Pod失败之后会被控制器（比如ReplicationController/ReplicaSet）重启，但这是一个全新的POD，关键是POD的IP发生了变化。那么该POD提供给的服务就无法直接被外部依赖。
为此，Kubernetes引入了Service.

A Kubernetes Service is an abstraction which defines a logical set of Pods and a policy by which to access them - sometimes called 微服务（a micro-service）。

The set of Pods targeted by a Service is(usually) determined by a ***Label Selector***。这样当外界访问Pod提供的服务时，不必直接访问Pod本身，可以通过Service来访问。Services的IP在生命周期中时不变的，实现了对后端Pod的代理，以此实现了前后端的松耦合。
