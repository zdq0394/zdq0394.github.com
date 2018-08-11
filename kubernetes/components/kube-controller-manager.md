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
* --**address** ip: kube-controller-manager监听的IP地址，默认是`0.0.0.0`，监听所有端口。
* --**port** int: Default: 10252. The port on which to serve HTTP insecurely without authentication and authorization. If 0, don't serve HTTPS at all. See --secure-port instead.
* --**bind-address** ip: Default: 0.0.0.0. The IP address on which to listen for the --secure-port port. The associated interface(s) must be reachable by the rest of the cluster, and by CLI/web clients. If blank, all interfaces will be used (0.0.0.0 for all IPv4 interfaces and :: for all IPv6 interfaces).
* --**secure-port** int: The port on which to serve HTTPS with authentication and authorization. If 0, don't serve HTTPS at all.
* --cert-dir string: Default: "/var/run/kubernetes": The directory where the TLS certs are located. If --tls-cert-file and --tls-private-key-file are provided, this flag will be ignored.
* --cluster-name string: Default: "kubernetes". The instance prefix for the cluster.
* --cluster-signing-cert-file string: Default: "/etc/kubernetes/ca/ca.pem". Filename containing a PEM-encoded X509 CA certificate used to issue cluster-scoped certificates
* --cluster-signing-key-file string: Default: "/etc/kubernetes/ca/ca.key". Filename containing a PEM-encoded RSA or ECDSA private key used to sign cluster-scoped certificates
* --configure-cloud-routes: Default: true. Should CIDRs allocated by allocate-node-cidrs be configured on the cloud provider.
* --contention-profiling: Enable lock contention profiling, if profiling is enabled
* --controller-start-interval duration. Interval between starting controller managers.
* --controllers stringSlice: Default: `[*]`. A list of controllers to enable. '*' enables all on-by-default controllers, 'foo' enables the controller named 'foo', '-foo' disables the controller named 'foo'.
    Disabled-by-default controllers: **bootstrapsigner, tokencleaner**
    
    All controllers: 
    * attachdetach
    * bootstrapsigner
    * clusterrole-aggregation
    * cronjob
    * csrapproving
    * csrcleaner
    * csrsigning
    * daemonset
    * deployment
    * disruption
    * endpoint
    * garbagecollector
    * horizontalpodautoscaling
    * job
    * namespace
    * nodeipam
    * nodelifecycle
    * persistentvolume-binder
    * persistentvolume-expander
    * podgc
    * pv-protection
    * pvc-protection
    * replicaset
    * replicationcontroller
    * resourcequota
    * route
    * service
    * serviceaccount
    * serviceaccount-token
    * statefulset
    * tokencleaner
    * ttl
* --deployment-controller-sync-period duration: Default: 30s. Period for syncing the deployments.
* --disable-attach-detach-reconcile-sync: Disable volume attach detach reconciler sync. Disabling this may cause volumes to be mismatched with pods. Use wisely.
* --enable-dynamic-provisioning: Default: true. Enable dynamic provisioning for environments that support it.
* --enable-garbage-collector: Default: true. Enables the generic garbage collector. MUST be synced with the corresponding flag of the kube-apiserver.
* --enable-hostpath-provisioner: Enable HostPath PV provisioning when running without a cloud provider. This allows testing and development of provisioning features. HostPath provisioning is not supported in any way, won't work in a multi-node cluster, and should not be used for anything other than testing or development.
* --enable-taint-manager: Default: true. **WARNING**: Beta feature. If set to true enables NoExecute Taints and will evict all not-tolerating Pod running on Nodes tainted with this kind of Taints.
* --feature-gates mapStringBool: A set of key=value pairs that describe feature gates for alpha/experimental features. 
    Options are:
    * APIListChunking=true|false (BETA - default=true)
    * APIResponseCompression=true|false (ALPHA - default=false)
    * AdvancedAuditing=true|false (BETA - default=true)
    * AllAlpha=true|false (ALPHA - default=false)
    * AppArmor=true|false (BETA - default=true)
    * AttachVolumeLimit=true|false (ALPHA - default=false)
    * BalanceAttachedNodeVolumes=true|false (ALPHA - default=false)
    * BlockVolume=true|false (ALPHA - default=false)
    * CPUManager=true|false (BETA - default=true)
    * CRIContainerLogRotation=true|false (BETA - default=true)
    * CSIBlockVolume=true|false (ALPHA - default=false)
    * CSIPersistentVolume=true|false (BETA - default=true)
    * CustomPodDNS=true|false (BETA - default=true)
    * CustomResourceSubresources=true|false (BETA - default=true)
    * CustomResourceValidation=true|false (BETA - default=true)
    * DebugContainers=true|false (ALPHA - default=false)
    * DevicePlugins=true|false (BETA - default=true)
    * DynamicKubeletConfig=true|false (BETA - default=true)
    * DynamicProvisioningScheduling=true|false (ALPHA - default=false)
    * EnableEquivalenceClassCache=true|false (ALPHA - default=false)
    * ExpandInUsePersistentVolumes=true|false (ALPHA - default=false)
    * ExpandPersistentVolumes=true|false (BETA - default=true)
    * ExperimentalCriticalPodAnnotation=true|false (ALPHA - default=false)
    * ExperimentalHostUserNamespaceDefaulting=true|false (BETA - default=false)
    * GCERegionalPersistentDisk=true|false (BETA - default=true)
    * HugePages=true|false (BETA - default=true)
    * HyperVContainer=true|false (ALPHA - default=false)
    * Initializers=true|false (ALPHA - default=false)
    * KubeletPluginsWatcher=true|false (ALPHA - default=false)
    * LocalStorageCapacityIsolation=true|false (BETA - default=true)
    * MountContainers=true|false (ALPHA - default=false)
    * MountPropagation=true|false (BETA - default=true)
    * PersistentLocalVolumes=true|false (BETA - default=true)
    * PodPriority=true|false (BETA - default=true)
    * PodReadinessGates=true|false (BETA - default=false)
    * PodShareProcessNamespace=true|false (ALPHA - default=false)
    * QOSReserved=true|false (ALPHA - default=false)
    * ReadOnlyAPIDataVolumes=true|false (DEPRECATED - default=true)
    * ResourceLimitsPriorityFunction=true|false (ALPHA - default=false)
    * ResourceQuotaScopeSelectors=true|false (ALPHA - default=false)
    * RotateKubeletClientCertificate=true|false (BETA - default=true)
    * RotateKubeletServerCertificate=true|false (ALPHA - default=false)
    * RunAsGroup=true|false (ALPHA - default=false)
    * ScheduleDaemonSetPods=true|false (ALPHA - default=false)
    * ServiceNodeExclusion=true|false (ALPHA - default=false)
    * ServiceProxyAllowExternalIPs=true|false (DEPRECATED - default=false)
    * StorageObjectInUseProtection=true|false (default=true)
    * StreamingProxyRedirects=true|false (BETA - default=true)
    * SupportIPVSProxyMode=true|false (default=true)
    * SupportPodPidsLimit=true|false (ALPHA - default=false)
    * Sysctls=true|false (BETA - default=true)
    * TaintBasedEvictions=true|false (ALPHA - default=false)
    * TaintNodesByCondition=true|false (ALPHA - default=false)
    * TokenRequest=true|false (ALPHA - default=false)
    * TokenRequestProjection=true|false (ALPHA - default=false)
    * VolumeScheduling=true|false (BETA - default=true)
    * VolumeSubpath=true|false (default=true)
    * VolumeSubpathEnvExpansion=true|false (ALPHA - default=false)
* -h, --help: help for kube-controller-manager
* --kubeconfig string. Path to kubeconfig file with authorization and master location information.
* --large-cluster-size-threshold int32: Default: 50. Number of nodes from which NodeController treats the cluster as large for the eviction logic purposes. --secondary-node-eviction-rate is implicitly overridden to 0 for clusters this size or smaller.
* --leader-elect: Default: true. Start a leader election client and gain leadership before executing the main loop. Enable this when running replicated components for high availability.
* --log-flush-frequency duration: Default: 5s. Maximum number of seconds between log flushes。
* --master string. The address of the Kubernetes API server (overrides any value in kubeconfig).
* --pod-eviction-timeout duration: Default: 5m0s. The grace period for deleting pods on failed nodes.
* --root-ca-file string: If set, this root certificate authority will be included in service account's token secret. This must be a valid PEM-encoded CA bundle.
* --service-cluster-ip-range string. CIDR Range for Services in cluster. Requires --allocate-node-cidrs to be true
* --terminated-pod-gc-threshold int32: Default: 12500. Number of terminated pods that can exist before the terminated pod garbage collector starts deleting terminated pods. If <= 0, the terminated pod garbage collector is disabled.
* --tls-cert-file string: File containing the default x509 Certificate for HTTPS. (CA cert, if any, concatenated after server cert). If HTTPS serving is enabled, and --tls-cert-file and --tls-private-key-file are not provided, a self-signed certificate and key are generated for the public address and saved to the directory specified by --cert-dir.
* --tls-min-version string: Minimum TLS version supported. Possible values: VersionTLS10, VersionTLS11, VersionTLS12
* --tls-private-key-file string: File containing the default x509 private key matching --tls-cert-file.
* --use-service-account-credentials: If true, use individual service account credentials for each controller.
* --version version[=true]: Print version information and quit

