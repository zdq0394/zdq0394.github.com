# Kube-scheduler
## 概述
Kubernetes scheduler是一个`policy-rich`, `topology-aware`, `workload-specific` function that significantly impacts `availability`, `performance`, and `capacity`. 

The scheduler needs to take into account individual and collective resource requirements, quality of service requirements, hardware/software/policy constraints, affinity and anti-affinity specifications, data locality, inter-workload interference, deadlines, and so on. 

Workload-specific requirements will be exposed through the API as necessary.

## Options
* --address string: 监听的IP地址，默认是`0.0.0.0`，监听所有接口。
* --algorithm-provider string: 调度算法provider，包括`ClusterAutoscalerProvider`和`DefaultProvider`两个选项。
* --config string: kube-scheduler的配置文件
* --contention-profiling: Enable lock contention profiling, if profiling is enabled
* --feature-gates mapStringBool: A set of key=value pairs that describe feature gates for alpha/experimental features. 
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
* --kube-api-burst int32: Burst to use while talking with kubernetes apiserver (default 100)
* --kube-api-content-type string: Content type of requests sent to apiserver. (default "application/vnd.kubernetes.protobuf")
* --kube-api-qps float32: QPS to use while talking with kubernetes apiserver (default 50)
* --kubeconfig string: 访问apiserver的配置，包括认证信息和master地址。
* --leader-elect: Start a leader election client and gain leadership before executing the main loop. Enable this when running replicated components for high availability.
* --lock-object-name string: Define the name of the lock object. (default "kube-scheduler")
* --lock-object-namespace string: Define the namespace of the lock object. (default "kube-system")
* --master string: kube-apiserver的地址。
* --policy-config-file string: File with scheduler policy configuration. This file is used if policy ConfigMap is not provided or --use-legacy-policy-config==true
* --policy-configmap string: Name of the ConfigMap object that contains scheduler's policy configuration. It must exist in the system namespace before scheduler initialization if --use-legacy-policy-config==false. The config must be provided as the value of an element in 'Data' map with the key='policy.cfg'
* --policy-configmap-namespace string: The namespace where policy ConfigMap is located. The system namespace will be used if this is not provided or is empty.
* --port int32: kube-scheduler的HTTP服务监听的端口，默认是10251。 
* --profiling: Enable profiling via web interface host:port/debug/pprof/
* --scheduler-name string: Name of the scheduler, used to select which pods will be processed by this scheduler, based on pod's "spec.SchedulerName". (default "default-scheduler")
* --use-legacy-policy-config: When set to true, scheduler will ignore policy ConfigMap and uses policy config file
* --version version[=true]: Print version information and quit
