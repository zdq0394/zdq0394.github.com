# Containerd
Containerd是一个`工业级`的`容器运行时`实现。Containerd强调简单性、健壮性和可移植性。

Conainderd可以管理容器的整个生命周期：镜像的转移和存储、容器的执行和监视以及底层的存储挂载和网络接入。不像`runc`只实现了容器生命周期的管理。

Containerd适合用来嵌入一个更大的系统——比如docker中，不适合直接使用。