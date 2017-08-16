# Services
Kubernetes Pods不是持久的（are mortal），并且无法被恢复。
A Kubernetes Service is an abstraction which defines a logical set of Pods and a policy by which to access them - sometimes called a micro-service.

The set of Pods targeted by a Service is(usually) determined by a Label Selector.