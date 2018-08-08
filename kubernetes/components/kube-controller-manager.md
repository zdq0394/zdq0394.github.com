# kube-controller-manager
## 概述
Kube-controller-manager部署在k8s master节点上，用来控制controllers。
逻辑上，每个controller都是一个单独的执行流。
为了减少复杂度，所有的controllers被编译成一个二进制文件，并在一个进程中运行。

在Kubernetes中，一个controller是这样一个control loop：通过api server监测集群的共享状态，并进行一定的动作，维持集群保持在**期望状态**

这些控制器包括：
* Node Controller： 对节点的`go down`作出响应。
* Replication Controller： 对系统中的每一个replication controller object，维持正确的pod数目。
* Endpoints Controller： Populates endpoints objects。
* Service Account & Token Controllers： 为新的namespace创建默认的accounts和API access tokens。[service accounts](../serviceaccounts/admin-guide-to-sa.md)

## Options
* --**address** ip: Default: 0.0.0.0
* --**port** int: Default: 10252. The port on which to serve HTTP insecurely without authentication and authorization. If 0, don't serve HTTPS at all. See --secure-port instead.
* --allocate-node-cidrs: Should CIDRs for Pods be allocated and set on the cloud provider.
* --attach-detach-reconcile-sync-period duration: Default: 1m0s. The reconciler sync wait time between volume attach detach. This duration must be larger than one second, and increasing this value from the default may allow for volumes to be mismatched with pods.
* --azure-container-registry-config string: Path to the file containing Azure container registry configuration information.
* --**bind-address** ip: Default: 0.0.0.0. The IP address on which to listen for the --secure-port port. The associated interface(s) must be reachable by the rest of the cluster, and by CLI/web clients. If blank, all interfaces will be used (0.0.0.0 for all IPv4 interfaces and :: for all IPv6 interfaces).
* --**secure-port** int: The port on which to serve HTTPS with authentication and authorization. If 0, don't serve HTTPS at all.
* --cert-dir string: Default: "/var/run/kubernetes": The directory where the TLS certs are located. If --tls-cert-file and --tls-private-key-file are provided, this flag will be ignored.
* --cidr-allocator-type string: Default: "RangeAllocator". Type of CIDR allocator to use
* --cloud-config string: The path to the cloud provider configuration file. Empty string for no configuration file.
* --cloud-provider string: The provider for cloud services. Empty string for no provider.
* --cluster-cidr string: CIDR Range for Pods in cluster. Requires --allocate-node-cidrs to be true
* --cluster-name string: Default: "kubernetes". The instance prefix for the cluster.
* --cluster-signing-cert-file string: Default: "/etc/kubernetes/ca/ca.pem". Filename containing a PEM-encoded X509 CA certificate used to issue cluster-scoped certificates
* --cluster-signing-key-file string: Default: "/etc/kubernetes/ca/ca.key". Filename containing a PEM-encoded RSA or ECDSA private key used to sign cluster-scoped certificates
* --concurrent-deployment-syncs int32: Default: 5. The number of deployment objects that are allowed to sync concurrently. Larger number = more responsive deployments, but more CPU (and network) load
* --concurrent-endpoint-syncs int32: Default: 5. The number of endpoint syncing operations that will be done concurrently. Larger number = faster endpoint updating, but more CPU (and network) load
* --concurrent-gc-syncs int32: Default: 20. The number of garbage collector workers that are allowed to sync concurrently.
* --concurrent-namespace-syncs int32: Default: 10. The number of namespace objects that are allowed to sync concurrently. Larger number = more responsive namespace termination, but more CPU (and network) load
* --concurrent-replicaset-syncs int32: Default: 5. The number of replica sets that are allowed to sync concurrently. Larger number = more responsive replica management, but more CPU (and network) load
* --concurrent-resource-quota-syncs int32: Default: 5. The number of resource quotas that are allowed to sync concurrently. Larger number = more responsive quota management, but more CPU (and network) load
* --concurrent-service-syncs int32: Default: 1. The number of services that are allowed to sync concurrently. Larger number = more responsive service management, but more CPU (and network) load
* --concurrent-serviceaccount-token-syncs int32: Default: 5. The number of service account token objects that are allowed to sync concurrently. Larger number = more responsive token generation, but more CPU (and network) load
* --concurrent_rc_syncs int32: Default: 5. The number of replication controllers that are allowed to sync concurrently. Larger number = more responsive replica management, but more CPU (and network) load
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
* --experimental-cluster-signing-duration duration: Default: 8760h0m0s. The length of duration signed certificates will be given.
* --external-cloud-volume-plugin string. The plugin to use when cloud provider is set to external. Can be empty, should only be set when cloud-provider is external. Currently used to allow node and volume controllers to work for in tree cloud providers.
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
* --flex-volume-plugin-dir string: Default: "/usr/libexec/kubernetes/kubelet-plugins/volume/exec/". Full path of the directory in which the flex volume plugin should search for additional third party volume plugins.
* -h, --help: help for kube-controller-manager
* --horizontal-pod-autoscaler-downscale-delay duration: Default: 5m0s. The period since last downscale, before another downscale can be performed in horizontal pod autoscaler.
* --horizontal-pod-autoscaler-sync-period duration: Default: 30s. The period for syncing the number of pods in horizontal pod autoscaler.
* --horizontal-pod-autoscaler-tolerance float: Default: 0.1. The minimum change (from 1.0) in the desired-to-actual metrics ratio for the horizontal pod autoscaler to consider scaling.
* --horizontal-pod-autoscaler-upscale-delay duration: Default: 3m0s. The period since last upscale, before another upscale can be performed in horizontal pod autoscaler.
* --horizontal-pod-autoscaler-use-rest-clients: Default: true. If set to true, causes the horizontal pod autoscaler controller to use REST clients through the kube-aggregator, instead of using the legacy metrics client through the API server proxy. This is required for custom metrics support in the horizontal pod autoscaler.
* --http2-max-streams-per-connection int: The limit that the server gives to clients for the maximum number of streams in an HTTP/2 connection. Zero means to use golang's default.
* --insecure-experimental-approve-all-kubelet-csrs-for-group string: This flag does nothing.
* --kube-api-burst int32: Default: 30. Burst to use while talking with kubernetes apiserver.
* --kube-api-content-type string: Default: "application/vnd.kubernetes.protobuf". Content type of requests sent to apiserver.
* --kube-api-qps float32: Default: 20. QPS to use while talking with kubernetes apiserver.
* --kubeconfig string. Path to kubeconfig file with authorization and master location information.
* --large-cluster-size-threshold int32: Default: 50. Number of nodes from which NodeController treats the cluster as large for the eviction logic purposes. --secondary-node-eviction-rate is implicitly overridden to 0 for clusters this size or smaller.
* --leader-elect: Default: true. Start a leader election client and gain leadership before executing the main loop. Enable this when running replicated components for high availability.
* --leader-elect-lease-duration duration: Default: 15s. The duration that non-leader candidates will wait after observing a leadership renewal until attempting to acquire leadership of a led but unrenewed leader slot. This is effectively the maximum duration that a leader can be stopped before it is replaced by another candidate. This is only applicable if leader election is enabled.
* --leader-elect-renew-deadline duration: Default: 10s. The interval between attempts by the acting master to renew a leadership slot before it stops leading. This must be less than or equal to the lease duration. This is only applicable if leader election is enabled.
* --leader-elect-resource-lock endpoints: Default: "endpoints". The type of resource object that is used for locking during leader election. Supported options are endpoints (default) and `configmaps`.
* --leader-elect-retry-period duration: Default: 2s. The duration the clients should wait between attempting acquisition and renewal of a leadership. This is only applicable if leader election is enabled.
* --log-flush-frequency duration: Default: 5s. Maximum number of seconds between log flushes
* --master string. The address of the Kubernetes API server (overrides any value in kubeconfig).
* --min-resync-period duration: Default: 12h0m0s. The resync period in reflectors will be random between MinResyncPeriod and 2*MinResyncPeriod.
* --namespace-sync-period duration: Default: 5m0s. The period for syncing namespace life-cycle updates
* --node-cidr-mask-size int32: Default: 24. Mask size for node cidr in cluster.
* --node-eviction-rate float32: Default: 0.1. Number of nodes per second on which pods are deleted in case of node failure when a zone is healthy (see --unhealthy-zone-threshold for definition of healthy/unhealthy). Zone refers to entire cluster in non-multizone clusters.
* --node-monitor-grace-period duration: Default: 40s. Amount of time which we allow running Node to be unresponsive before marking it unhealthy. Must be N times more than kubelet's nodeStatusUpdateFrequency, where N means number of retries allowed for kubelet to post node status.
* --node-monitor-period duration: Default: 5s. The period for syncing NodeStatus in NodeController.
* --node-startup-grace-period duration: Default: 1m0s. Amount of time which we allow starting Node to be unresponsive before marking it unhealthy.
* --pod-eviction-timeout duration: Default: 5m0s. The grace period for deleting pods on failed nodes.
* --profiling: Enable profiling via web interface host:port/debug/pprof/
* --pv-recycler-increment-timeout-nfs int32: Default: 30. the increment of time added per Gi to ActiveDeadlineSeconds for an NFS scrubber pod
* --pv-recycler-minimum-timeout-hostpath int32: Default: 60. The minimum ActiveDeadlineSeconds to use for a HostPath Recycler pod. This is for development and testing only and will not work in a multi-node cluster.
* --pv-recycler-minimum-timeout-nfs int32: Default: 300. The minimum ActiveDeadlineSeconds to use for an NFS Recycler pod
* --pv-recycler-pod-template-filepath-hostpath string: The file path to a pod definition used as a template for HostPath persistent volume recycling. This is for development and testing only and will not work in a multi-node cluster.
* --pv-recycler-pod-template-filepath-nfs string: The file path to a pod definition used as a template for NFS persistent volume recycling
* --pv-recycler-timeout-increment-hostpath int32: Default: 30. the increment of time added per Gi to ActiveDeadlineSeconds for a HostPath scrubber pod. This is for development and testing only and will not work in a multi-node cluster.
* --pvclaimbinder-sync-period duration: Default: 15s. The period for syncing persistent volumes and persistent volume claims
* --resource-quota-sync-period duration: Default: 5m0s. The period for syncing quota usage status in the system
* --root-ca-file string: If set, this root certificate authority will be included in service account's token secret. This must be a valid PEM-encoded CA bundle.
* --route-reconciliation-period duration: Default: 10s. The period for reconciling routes created for Nodes by cloud provider.
* --secondary-node-eviction-rate float32: Default: 0.01. Number of nodes per second on which pods are deleted in case of node failure when a zone is unhealthy (see * * --unhealthy-zone-threshold for definition of healthy/unhealthy). Zone refers to entire cluster in non-multizone clusters. This value is implicitly overridden to 0 if the cluster size is smaller than --large-cluster-size-threshold.
* --service-cluster-ip-range string. CIDR Range for Services in cluster. Requires --allocate-node-cidrs to be true
* --terminated-pod-gc-threshold int32: Default: 12500. Number of terminated pods that can exist before the terminated pod garbage collector starts deleting terminated pods. If <= 0, the terminated pod garbage collector is disabled.
* --tls-cert-file string: File containing the default x509 Certificate for HTTPS. (CA cert, if any, concatenated after server cert). If HTTPS serving is enabled, and --tls-cert-file and --tls-private-key-file are not provided, a self-signed certificate and key are generated for the public address and saved to the directory specified by --cert-dir.
* --tls-cipher-suites stringSlice: Comma-separated list of cipher suites for the server. If omitted, the default Go cipher suites will be use. Possible values: TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA,TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256,TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA,TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_ECDSA_WITH_RC4_128_SHA,TLS_ECDHE_RSA_WITH_3DES_EDE_CBC_SHA,TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA,TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_RSA_WITH_RC4_128_SHA,TLS_RSA_WITH_3DES_EDE_CBC_SHA,TLS_RSA_WITH_AES_128_CBC_SHA,TLS_RSA_WITH_AES_128_CBC_SHA256,TLS_RSA_WITH_AES_128_GCM_SHA256,TLS_RSA_WITH_AES_256_CBC_SHA,TLS_RSA_WITH_AES_256_GCM_SHA384,TLS_RSA_WITH_RC4_128_SHA
* --tls-min-version string: Minimum TLS version supported. Possible values: VersionTLS10, VersionTLS11, VersionTLS12
* --tls-private-key-file string: File containing the default x509 private key matching --tls-cert-file.
* --tls-sni-cert-key namedCertKey: Default: []. A pair of x509 certificate and private key file paths, optionally suffixed with a list of domain patterns which are fully qualified domain names, possibly with prefixed wildcard segments. If no domain patterns are provided, the names of the certificate are extracted. Non-wildcard matches trump over wildcard matches, explicit domain patterns trump over extracted names. For multiple key/certificate pairs, use the --tls-sni-cert-key multiple times. Examples: "example.crt,example.key" or "foo.crt,foo.key:*.foo.com,foo.com".
* --unhealthy-zone-threshold float32: Default: 0.55. Fraction of Nodes in a zone which needs to be not Ready (minimum 3) for zone to be treated as unhealthy.
* --use-service-account-credentials: If true, use individual service account credentials for each controller.
* --version version[=true]: Print version information and quit

