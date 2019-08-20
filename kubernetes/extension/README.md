# Extending Kubernetes
## 扩展模式
* Controller模式
典型的，一个kubernetes apiserver的客户端程序，通过ListWatch监视着apiserver中的objects，根据其中的Spec，do something， 然后更新Status字段。
* Remote Webhook模式
Kubernetes作为客户端，通过网络请求与Remote Webhook交互。
* Binary Plugin模式
Kubelet/Kubectl执行`二进制可执行代码`与其它进行交互，比如cni plugin、device plugin等。
## 扩展点
* Kubectl
* API Server
    * authentication
    * authorization
    * dynamic admission control
    * CRD
    * Aggregation Layer
        * Service Catalog
* Scheduler
* Controllers
    * Operator Pattern：combination of a CRD and a control loop(controller)。
* Kubelet
    * Storage Plugins
    * Device Plugins
    * Network Plugins