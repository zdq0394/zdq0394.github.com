# Kubernetes对GPU的支持
Kubernetes从**v1.6**开始支持NVIDIA GPUs。
## alpha.kubernetes.io/nvidia-gpu
该特性在Kubernets**1.6、1.7、1.8和1.9**都可以使用；在1.10中将被deprecated；在1.1中将被removed。

使用准备
1. 开启**--feature-gates="Accelerators=true"**
2. 使用docker engine。
3. 节点上需要安装**NVIDIA驱动**，否则Kubelet检测不到NVIDIA GPUs。

当以上条件满足后，Kubernetes将暴露资源**alpha.kubernetes.io/nvidia-gpu**，以供scheduler调度。
然后可以在pod的yaml文件中配置中**alpha.kubernetes.io/nvidia-gpu**来使用GPUs。

1. GPU仅支持**limits**选项：
    * 可以只指定**limits**，而不指定**requests**，Kubernetes将把**limits**的值作为**requests**的默认值。
    * 可以同时指定**limits**和**requests**，但是两者必须一致。
    * **不能**只指定**requests**而不指定**limits**。
2. 容器（pod）之间不能共享GPUs。GPU不能过载使用（overcommitting）。
3. 一个容器可以请求一个或者多个GPUs。不能只请求GPU的一部分。

如果要是用**alpha.kubernetes.io/nvidia-gpu**，还必须把宿主机上NVIDIA的lib包（libcuda.so, libnvidia.so）mount到容器上。

例子：
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: cuda-vector-add
spec:
  restartPolicy: OnFailure
  containers:
    - name: cuda-vector-add
      # https://github.com/kubernetes/kubernetes/blob/v1.7.11/test/images/nvidia-cuda/Dockerfile
      image: "k8s.gcr.io/cuda-vector-add:v0.1"
      resources:
        limits:
          alpha.kubernetes.io/nvidia-gpu: 1 # requesting 1 GPU
      volumeMounts:
        - name: "nvidia-libraries"
          mountPath: "/usr/local/nvidia/lib64"
  volumes:
    - name: "nvidia-libraries"
      hostPath:
        path: "/usr/lib/nvidia-375"
```

## NVIDIA GPU device plugins
从1.8开始，还可以通过**device plugins**的方式使用GPU。

使用准备：
* 开启特性**--feature-gates="DevicePlugins=true"**以支持device plugins；在1.10起，该特性默认开启。
* 节点上安装NVIDIA驱动和NVIDIA GPU device plugin。

当以上条件满足后，Kubernetes将暴露资源**nvidia.com/gpu**，以供scheduler调度。
然后可以在pod的yaml文件中配置中**nvidia.com/gpu**来使用GPUs。

1. GPU仅支持**limits**选项：
    * 可以只指定**limits**，而不指定**requests**，Kubernetes将把**limits**的值作为**requests**的默认值。
    * 可以同时指定**limits**和**requests**，但是两者必须一致。
    * **不能**只指定**requests**而不指定**limits**。
2. 容器（pod）之间不能共享GPUs。GPU不能过载使用（overcommitting）。
3. 一个容器可以请求一个或者多个GPUs。不能只请求GPU的一部分。

例子：
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: cuda-vector-add
spec:
  restartPolicy: OnFailure
  containers:
    - name: cuda-vector-add
      # https://github.com/kubernetes/kubernetes/blob/v1.7.11/test/images/nvidia-cuda/Dockerfile
      image: "k8s.gcr.io/cuda-vector-add:v0.1"
      resources:
        limits:
          nvidia.com/gpu: 1 # requesting 1 GPU
```

### 安装NVIDIA GPU device plugin
NVIDIA GPU device plugin的安装需要满足如下条件：
* 安装NVIDIA驱动
* 安装[nvidia-docker 2.0](https://github.com/NVIDIA/nvidia-docker)
* docker的默认运行时配置为nvidia-container-runtime，而不是runc。
* NVIDIA drivers ~= 361.93

当以上条件满足，并且kubernetes集群处于running中，执行一下命令部署NVIDIA device plugin：
```yaml
# For Kubernetes v1.8
kubectl create -f https://raw.githubusercontent.com/NVIDIA/k8s-device-plugin/v1.8/nvidia-device-plugin.yml

# For Kubernetes v1.9
kubectl create -f https://raw.githubusercontent.com/NVIDIA/k8s-device-plugin/v1.9/nvidia-device-plugin.yml
```

## 集群包括不同类型的GPU

通过**node label**和**node selector**机制实现对GPU type的绑定。 这也说明只能以node为粒度配置GPU。一个node上只配置一种类型的GPU。

首先，对node打上label：
```
# Label your nodes with the accelerator type they have.
kubectl label nodes <node-with-k80> accelerator=nvidia-tesla-k80
kubectl label nodes <node-with-p100> accelerator=nvidia-tesla-p100
```
然后在pod的配置文件中指定selector：
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: cuda-vector-add
spec:
  restartPolicy: OnFailure
  containers:
    - name: cuda-vector-add
      # https://github.com/kubernetes/kubernetes/blob/v1.7.11/test/images/nvidia-cuda/Dockerfile
      image: "k8s.gcr.io/cuda-vector-add:v0.1"
      resources:
        limits:
          nvidia.com/gpu: 1
  nodeSelector:
    accelerator: nvidia-tesla-p100 # or nvidia-tesla-k80 etc.
```

## 学习参考
* https://github.com/Langhalsdino/Kubernetes-GPU-Guide
* https://zhuanlan.zhihu.com/p/27376696

