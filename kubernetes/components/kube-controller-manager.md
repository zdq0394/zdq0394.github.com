# kube-controller-manager
Kube-controller-manager部署在k8s master节点上，用来控制controllers。
逻辑上，每个controller都是一个单独的进程。
为了减少复杂度，所有的controllers被编译成一个二进制文件，并在一个进程中运行。

这些控制器包括：
* Node Controller： 对节点的`go down`作出响应。
* Replication Controller： 对系统中的每一个replication controller object，维持正确的pod数目。
* Endpoints Controller： Populates endpoints objects。
* Service Account & Token Controllers： 为新的namespace创建默认的accounts和API access tokens。[service accounts](../serviceaccounts/admin-guide-to-sa.md)