# kube-controller-manager
## 概述
Kube-controller-manager部署在k8s master节点上，用来控制controllers。
逻辑上，每个controller都是一个单独的执行流。
为了减少复杂度，所有的controllers被编译成一个二进制文件，并在一个进程中运行。

在Kubernetes中，一个controller是这样一个control loop：通过api server监测集群的共享状态，并进行一定的动作，维持集群保持在**期望状态**。

这些控制器包括：
* Node Controller： 对节点的`go down`作出响应。
* Replication Controller： 对系统中的每一个`replication controller object`维持正确的pod数目。
* Endpoints Controller： 生成`endpoints`对象。
* Service Account & Token Controllers： 为新的namespace创建默认的accounts和API access tokens。[service accounts](../serviceaccounts/admin-guide-to-sa.md)

## Options
* --address ip： Kube-controller-manager的监听地址，默认是`0.0.0.0`，监听所有接口。
* --port int32： Kube-controller-manager的http服务的监听端口，默认是`10252`。
* --cidr-allocator-type string：CIDR的分配器，默认是`RangeAllocator`。
* --cluster-name string：The instance prefix for the cluster (default "kubernetes")。
* --controllers stringSlice：要开启的控制器。比如serviceaccount,serviceaccount-token,tokencleaner
* --enable-dynamic-provisioning：Enable dynamic provisioning for environments that support it. (default true)
* --enable-hostpath-provisioner：Enable HostPath PV provisioning when running without a cloud provider. This allows testing and development of provisioning features.  HostPath provisioning is not supported in any way, won't work in a multi-node cluster, and should not be used for anything other than testing or development.
* --enable-taint-manager：WARNING: Beta feature. If set to true enables NoExecute Taints and will evict all not-tolerating Pod running on Nodes tainted with this kind of Taints. (default true)
* --feature-gates mapStringBool：A set of key=value pairs that describe feature gates for alpha/experimental features. 
    Options are:
    * APIListChunking=true|false (BETA - default=true)
    * APIResponseCompression=true|false (ALPHA - default=false)
    * Accelerators=true|false (ALPHA - default=false)
    * AdvancedAuditing=true|false (BETA - default=true)
    * AllAlpha=true|false (ALPHA - default=false)
    * AllowExtTrafficLocalEndpoints=true|false (default=true)
    * AppArmor=true|false (BETA - default=true)
    * BlockVolume=true|false (ALPHA - default=false)
    * CPUManager=true|false (ALPHA - default=false)
    * CSIPersistentVolume=true|false (ALPHA - default=false)
    * CustomPodDNS=true|false (ALPHA - default=false)
    * CustomResourceValidation=true|false (BETA - default=true)
    * DebugContainers=true|false (ALPHA - default=false)
    * DevicePlugins=true|false (ALPHA - default=false)
    * DynamicKubeletConfig=true|false (ALPHA - default=false)
    * EnableEquivalenceClassCache=true|false (ALPHA - default=false)
    * ExpandPersistentVolumes=true|false (ALPHA - default=false)
    * ExperimentalCriticalPodAnnotation=true|false (ALPHA - default=false)
    * ExperimentalHostUserNamespaceDefaulting=true|false (BETA - default=false)
    * HugePages=true|false (ALPHA - default=false)
    * Initializers=true|false (ALPHA - default=false)
    * KubeletConfigFile=true|false (ALPHA - default=false)
    * LocalStorageCapacityIsolation=true|false (ALPHA - default=false)
    * MountContainers=true|false (ALPHA - default=false)
    * MountPropagation=true|false (ALPHA - default=false)
    * PVCProtection=true|false (ALPHA - default=false)
    * PersistentLocalVolumes=true|false (ALPHA - default=false)
    * PodPriority=true|false (ALPHA - default=false)
    * ResourceLimitsPriorityFunction=true|false (ALPHA - default=false)
    * RotateKubeletClientCertificate=true|false (BETA - default=true)
    * RotateKubeletServerCertificate=true|false (ALPHA - default=false)
    * ServiceNodeExclusion=true|false (ALPHA - default=false)
    * StreamingProxyRedirects=true|false (BETA - default=true)
    * SupportIPVSProxyMode=true|false (BETA - default=false)
    * TaintBasedEvictions=true|false (ALPHA - default=false)
    * TaintNodesByCondition=true|false (ALPHA - default=false)
    * VolumeScheduling=true|false (ALPHA - default=false)
* --kube-api-burst int32：Burst to use while talking with kubernetes apiserver (default 30)
* --kube-api-content-type string：Content type of requests sent to apiserver. (default "application/vnd.kubernetes.protobuf")
* --kube-api-qps float32：QPS to use while talking with kubernetes apiserver (default 20)
* --kubeconfig string：访问kube-apiserver的认证信息和master地址文件。
* --leader-elect： Start a leader election client and gain leadership before executing the main loop. Enable this when running replicated components for high availability. (default true)
* --master string：Kube-apiserver的master地址，将会覆盖kubeconfig中指定的地址。
* --root-ca-file string：如果设置，“根证书”ca将会被加到service account的token secret中。
* --service-account-private-key-file string：Filename containing a PEM-encoded private RSA or ECDSA key used to sign service account tokens.
* --service-cluster-ip-range string：CIDR Range for Services in cluster. Requires --allocate-node-cidrs to be true
* --use-service-account-credentials：If true, use individual service account credentials for each controller.
* --version version[=true]：Print version information and quit