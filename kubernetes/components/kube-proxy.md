# Kube-proxy
## 概述
Kubernetes network proxy(Kube-proxy)运行在每个node节点上。
Kubernetes API定义的services都会通过Kube-Proxy应用到每个节点，可以进行如下功能：
* 简单TCP/UDP转发
* TCP/UDP流量的轮询负载均衡
## Kube-Proxy Options
* --azure-container-registry-config string: Path to the file containing Azure container registry configuration information.
* --bind-address 0.0.0.0: Default: 0.0.0.0. The IP address for the proxy server to serve on (set to 0.0.0.0 for all IPv4 interfaces and `::` for all IPv6 interfaces)
* --cleanup: If true cleanup iptables and ipvs rules and exit.*
* --cleanup-ipvs: Default: true. If true make kube-proxy cleanup ipvs rules before running. Default is true
* --cluster-cidr string: The CIDR range of pods in the cluster. When configured, traffic sent to a Service cluster IP from outside this range will be masqueraded and traffic sent from pods to an external LoadBalancer IP will be directed to the respective cluster IP instead
* --config string: The path to the configuration file.
* --config-sync-period duration: Default: 15m0s. How often configuration from the apiserver is refreshed. Must be greater than 0.
* --conntrack-max-per-core int32: Default: 32768. Maximum number of NAT connections to track per CPU core (0 to leave the limit as-is and ignore conntrack-min).
* --conntrack-min int32: Default: 131072. Minimum number of conntrack entries to allocate, regardless of conntrack-max-per-core (set conntrack-max-per-core=0 to leave the limit as-is).
* --conntrack-tcp-timeout-close-wait duration: Default: 1h0m0s. NAT timeout for TCP connections in the CLOSE_WAIT state
* --conntrack-tcp-timeout-established duration: Default: 24h0m0s. Idle timeout for established TCP connections (0 to leave as-is)
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
* --healthz-bind-address 0.0.0.0: Default: 0.0.0.0:10256. The IP address and port for the health check server to serve on (set to 0.0.0.0 for all IPv4 interfaces and `::` for all IPv6 interfaces)
* --healthz-port int32: Default: 10256. The port to bind the health check server. Use 0 to disable.
* -h, --help: help for kube-proxy
* --hostname-override string: If non-empty, will use this string as identification instead of the actual hostname.
* --iptables-masquerade-bit int32: Default: 14. If using the pure iptables proxy, the bit of the fwmark space to mark packets requiring SNAT with. Must be within the range [0, 31].
* --iptables-min-sync-period duration: The minimum interval of how often the iptables rules can be refreshed as endpoints and services change (e.g. '5s', '1m', '2h22m').
* --iptables-sync-period duration: Default: 30s. The maximum interval of how often iptables rules are refreshed (e.g. '5s', '1m', '2h22m'). Must be greater than 0.
* --ipvs-exclude-cidrs stringSlice: A comma-separated list of CIDR's which the ipvs proxier should not touch when cleaning up IPVS rules.
* --ipvs-min-sync-period duration: The minimum interval of how often the ipvs rules can be refreshed as endpoints and services change (e.g. '5s', '1m', '2h22m').
* --ipvs-scheduler string: The ipvs scheduler type when proxy mode is ipvs
* --ipvs-sync-period duration: Default: 30s. The maximum interval of how often ipvs rules are refreshed (e.g. '5s', '1m', '2h22m'). Must be greater than 0.
* --kube-api-burst int32: Default: 10. Burst to use while talking with kubernetes apiserver
* --kube-api-content-type string: Default: "application/vnd.kubernetes.protobuf". Content type of requests sent to apiserver.
* --kube-api-qps float32: Default: 5. QPS to use while talking with kubernetes apiserver
* --kubeconfig string: Path to kubeconfig file with authorization information (the master location is set by the master flag).
* --log-flush-frequency duration: Default: 5s. Maximum number of seconds between log flushes
* --masquerade-all: If using the pure iptables proxy, SNAT all traffic sent via Service cluster IPs (this not commonly needed)
* --master string: The address of the Kubernetes API server (overrides any value in kubeconfig)
* --metrics-bind-address 0.0.0.0: Default: 127.0.0.1:10249. The IP address and port for the metrics server to serve on (set to 0.0.0.0 for all IPv4 interfaces and `::` for all IPv6 interfaces)
* --nodeport-addresses stringSlice: A string slice of values which specify the addresses to use for NodePorts. Values may be valid IP blocks (e.g. 1.2.3.0/24, 1.2.3.4/32). The default empty string slice ([]) means to use all local addresses.
* --oom-score-adj int32: Default: -999. The oom-score-adj value for kube-proxy process. Values must be within the range [-1000, 1000]
* --profiling: If true enables profiling via web interface on /debug/pprof handler.
* --proxy-mode ProxyMode: Which proxy mode to use: 'userspace' (older) or 'iptables' (faster) or 'ipvs' (experimental). If blank, use the best-available proxy (currently iptables). If the iptables proxy is selected, regardless of how, but the system's kernel or iptables versions are insufficient, this always falls back to the userspace proxy.
* --proxy-port-range port-range: Range of host ports (beginPort-endPort, single port or beginPort+offset, inclusive) that may be consumed in order to proxy service traffic. If (unspecified, 0, or 0-0) then ports will be randomly chosen.
* --udp-timeout duration: Default: 250ms. How long an idle UDP connection will be kept open (e.g. '250ms', '2s'). Must be greater than 0. Only applicable for proxy-mode=userspace
* --version version[=true]: Print version information and quit
* --write-config-to string: If set, write the default configuration values to this file and exit.
