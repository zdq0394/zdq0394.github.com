# kube-apiserver
## kube-apiserver概述
Kube-apiserver部署在k8s master节点上。
Kube-apiserver对外暴露kubernetes API，是kubernetes控制层的**前端**。
## kube-apiserver options
* --admission-control stringSlice: Admission is divided into two phases. (default [AlwaysAdmit])
    In the first phase, only mutating admission plugins run. In the second phase, only validating admission plugins run. The names in the below list may represent a validating plugin, a mutating plugin, or both. Within each phase, the plugins will run in the order in which they are passed to this flag. Comma-delimited list of: 
    * AlwaysAdmit
    * AlwaysDeny
    * AlwaysPullImages
    * DefaultStorageClass
    * DefaultTolerationSeconds
    * DenyEscalatingExec
    * DenyExecOnPrivileged
    * EventRateLimit
    * ExtendedResourceToleration
    * ImagePolicyWebhook
    * InitialResources
    * Initializers
    * LimitPodHardAntiAffinityTopology
    * LimitRanger
    * MutatingAdmissionWebhook
    * NamespaceAutoProvision
    * NamespaceExists
    * NamespaceLifecycle
    * NodeRestriction
    * OwnerReferencesPermissionEnforcement
    * PVCProtection
    * PersistentVolumeClaimResize
    * PersistentVolumeLabel
    * PodNodeSelector
    * PodPreset
    * PodSecurityPolicy
    * PodTolerationRestriction
    * Priority
    * ResourceQuota
    * SecurityContextDeny
    * ServiceAccount
    * ValidatingAdmissionWebhook
* --admission-control-config-file string: File with admission control configuration.
* --advertise-address ip: The IP address on which to advertise the apiserver to members of the cluster. This address must be reachable by the rest of the cluster. If blank, the --bind-address will be used. If --bind-address is unspecified, the host's default interface will be used.
* --**allow-privileged**: If true, allow privileged containers. [default=false]
* --anonymous-auth: Default: true. Enables anonymous requests to the secure port of the API server. Requests that are not rejected by another authentication method are treated as anonymous requests. Anonymous requests have a username of system:anonymous, and a group name of system:unauthenticated.
* --apiserver-count int: Default: 1. The number of apiservers running in the cluster, must be a positive number. (In use when --endpoint-reconciler-type=master-count is enabled.)
### audit
* --audit-log-batch-buffer-size int: Default: 10000. The size of the buffer to store events before batching and writing. Only used in batch mode.
* --audit-log-batch-max-size int: Default: 400. The maximum size of a batch. Only used in batch mode.
* --audit-log-batch-max-wait duration: Default: 30s. The amount of time to wait before force writing the batch that hadn't reached the max size. Only used in batch mode.
* --audit-log-batch-throttle-burst int: Default: 15. Maximum number of requests sent at the same moment if ThrottleQPS was not utilized before. Only used in batch mode.
* --audit-log-batch-throttle-enable: Whether batching throttling is enabled. Only used in batch mode.
* --audit-log-batch-throttle-qps float32: Default: 10. Maximum average number of batches per second. Only used in batch mode.
* --audit-log-format string: Default: "json". Format of saved audits. "legacy" indicates 1-line text format for each event. "json" indicates structured json format. Requires the 'AdvancedAuditing' feature gate. Known formats are legacy,json.
* --audit-log-maxage int: The maximum number of days to retain old audit log files based on the timestamp encoded in their filename.
* --audit-log-maxbackup int: The maximum number of old audit log files to retain.
* --audit-log-maxsize int: The maximum size in megabytes of the audit log file before it gets rotated.
* --audit-log-mode string: Default: "blocking". Strategy for sending audit events. Blocking indicates sending events should block server responses. Batch causes the backend to buffer and write events asynchronously. Known modes are batch,blocking.
* --audit-log-path string: If set, all requests coming to the apiserver will be logged to this file. '-' means standard out.
* --audit-log-truncate-enabled: Whether event and batch truncating is enabled.
* --audit-log-truncate-max-batch-size int: Default: 10485760. Maximum size of the batch sent to the underlying backend. Actual serialized size can be several hundreds of bytes greater. If a batch exceeds this limit, it is split into several batches of smaller size.
* --audit-log-truncate-max-event-size int: Default: 102400. Maximum size of the audit event sent to the underlying backend. If the size of an event is greater than this number, first request and response are removed, andif this doesn't reduce the size enough, event is discarded.
* --audit-log-version string: Default: "audit.k8s.io/v1beta1". API group and version used for serializing audit events written to log.
* --audit-policy-file string: Path to the file that defines the audit policy configuration. Requires the 'AdvancedAuditing' feature gate. With AdvancedAuditing, a profile is required to enable auditing.
* --audit-webhook-batch-buffer-size int: Default: 10000. The size of the buffer to store events before batching and writing. Only used in batch mode.
* --audit-webhook-batch-max-size int: Default: 400. The maximum size of a batch. Only used in batch mode.
* --audit-webhook-batch-max-wait duration: Default: 30s. The amount of time to wait before force writing the batch that hadn't reached the max size. Only used in batch mode.
* --audit-webhook-batch-throttle-burst int: Default: 15. Maximum number of requests sent at the same moment if ThrottleQPS was not utilized before. Only used in batch mode.
* --audit-webhook-batch-throttle-enable: Default: true. Whether batching throttling is enabled. Only used in batch mode.
* --audit-webhook-batch-throttle-qps float32: Default: 10. Maximum average number of batches per second. Only used in batch mode.
* --audit-webhook-config-file string: Path to a kubeconfig formatted file that defines the audit webhook configuration. Requires the 'AdvancedAuditing' feature gate.
* --audit-webhook-initial-backoff duration: Default: 10s. The amount of time to wait before retrying the first failed request.
* --audit-webhook-mode string: Default: "batch". Strategy for sending audit events. Blocking indicates sending events should block server responses. Batch causes the backend to buffer and write events asynchronously. Known modes are batch,blocking.
* --audit-webhook-truncate-enabled: Whether event and batch truncating is enabled.
* --audit-webhook-truncate-max-batch-size int: Default: 10485760. Maximum size of the batch sent to the underlying backend. Actual serialized size can be several hundreds of bytes greater. If a batch exceeds this limit, it is split into several batches of smaller size.
* --audit-webhook-truncate-max-event-size int: Default: 102400. Maximum size of the audit event sent to the underlying backend. If the size of an event is greater than this number, first request and response are removed, andif this doesn't reduce the size enough, event is discarded.
* --audit-webhook-version string: Default: "audit.k8s.io/v1beta1". API group and version used for serializing audit events written to webhook.
### authentication
* --authentication-token-webhook-cache-ttl duration: Default: 2m0s. The duration to cache responses from the webhook token authenticator.
* --authentication-token-webhook-config-file string: File with webhook configuration for token authentication in kubeconfig format. The API server will query the remote service to determine authentication for bearer tokens.
* --authorization-mode stringSlice: Default: [AlwaysAllow]. Ordered list of plug-ins to do authorization on secure port. Comma-delimited list of: AlwaysAllow,AlwaysDeny,ABAC,Webhook,RBAC,Node.
* --authorization-policy-file string:  File with authorization policy in csv format, used with --authorization-mode=ABAC, on the secure port.
* --authorization-webhook-cache-authorized-ttl duration: Default: 5m0s. The duration to cache 'authorized' responses from the webhook authorizer.
--authorization-webhook-cache-unauthorized-ttl duration     Default: 30s
The duration to cache 'unauthorized' responses from the webhook authorizer.
* --authorization-webhook-config-file string: File with webhook configuration in kubeconfig format, used with --authorization-mode=Webhook. The API server will query the remote service to determine access on the API server's secure port.
### azure
* --azure-container-registry-config string: Path to the file containing Azure container registry configuration information.
### basic
* --basic-auth-file string: If set, the file that will be used to admit requests to the secure port of the API server via http basic authentication.
* --bind-address ip: Default: 0.0.0.0. The IP address on which to listen for the --secure-port port. The associated interface(s) must be reachable by the rest of the cluster, and by CLI/web clients. If blank, all interfaces will be used (0.0.0.0 for all IPv4 interfaces and :: for all IPv6 interfaces).
### cert
* --cert-dir string：Default: "/var/run/kubernetes". The directory where the TLS certs are located. If --tls-cert-file and --tls-private-key-file are provided, this flag will be ignored.
* --client-ca-file string: If set, any request presenting a client certificate signed by one of the authorities in the client-ca-file is authenticated with an identity corresponding to the CommonName of the client certificate.
* --cloud-config string: The path to the cloud provider configuration file. Empty string for no configuration file.
* --cloud-provider string: The provider for cloud services. Empty string for no provider.
* --contention-profiling: Enable lock contention profiling, if profiling is enabled
* --cors-allowed-origins stringSlice: List of allowed origins for CORS, comma separated. An allowed origin can be a regular expression to support subdomain matching. If this list is empty CORS will not be enabled.
* --default-watch-cache-size int: Default: 100. Default watch cache size. If zero, watch cache will be disabled for resources that do not have a default watch size set.
* --delete-collection-workers int: Default: 1. Number of workers spawned for DeleteCollection call. These are used to speed up namespace cleanup.
* --deserialization-cache-size int: Number of deserialized json objects to cache in memory.
* --disable-admission-plugins stringSlice: admission plugins that should be disabled although they are in the default enabled plugins list. Comma-delimited list of admission plugins: AlwaysAdmit, AlwaysDeny, AlwaysPullImages, DefaultStorageClass, DefaultTolerationSeconds, DenyEscalatingExec, DenyExecOnPrivileged, EventRateLimit, ExtendedResourceToleration, ImagePolicyWebhook, Initializers, LimitPodHardAntiAffinityTopology, LimitRanger, MutatingAdmissionWebhook, NamespaceAutoProvision, NamespaceExists, NamespaceLifecycle, NodeRestriction, OwnerReferencesPermissionEnforcement, PersistentVolumeClaimResize, PersistentVolumeLabel, PodNodeSelector, PodPreset, PodSecurityPolicy, PodTolerationRestriction, Priority, ResourceQuota, SecurityContextDeny, ServiceAccount, StorageObjectInUseProtection, ValidatingAdmissionWebhook. The order of plugins in this flag does not matter.
* --enable-admission-plugins stringSlice: admission plugins that should be enabled in addition to default enabled ones. Comma-delimited list of admission plugins: AlwaysAdmit, AlwaysDeny, AlwaysPullImages, DefaultStorageClass, DefaultTolerationSeconds, DenyEscalatingExec, DenyExecOnPrivileged, EventRateLimit, ExtendedResourceToleration, ImagePolicyWebhook, Initializers, LimitPodHardAntiAffinityTopology, LimitRanger, MutatingAdmissionWebhook, NamespaceAutoProvision, NamespaceExists, NamespaceLifecycle, NodeRestriction, OwnerReferencesPermissionEnforcement, PersistentVolumeClaimResize, PersistentVolumeLabel, PodNodeSelector, PodPreset, PodSecurityPolicy, PodTolerationRestriction, Priority, ResourceQuota, SecurityContextDeny, ServiceAccount, StorageObjectInUseProtection, ValidatingAdmissionWebhook. The order of plugins in this flag does not matter.
* --enable-aggregator-routing: Turns on aggregator routing requests to endpoints IP rather than cluster IP.
* --enable-bootstrap-token-auth: Enable to allow secrets of type 'bootstrap.kubernetes.io/token' in the 'kube-system' namespace to be used for TLS bootstrapping authentication.
* --enable-garbage-collector: Default: true. Enables the generic garbage collector. MUST be synced with the corresponding flag of the kube-controller-manager.
* --enable-logs-handler: Default: true. If true, install a /logs handler for the apiserver logs.
* --enable-swagger-ui: Enables swagger ui on the apiserver at /swagger-ui
* --endpoint-reconciler-type string: Default: "lease". Use an endpoint reconciler (master-count, lease, none)
### etcd
* --etcd-cafile string: SSL Certificate Authority file used to secure etcd communication.
* --etcd-certfile string: SSL certification file used to secure etcd communication.
* --etcd-compaction-interval duration: Default: 5m0s. The interval of compaction requests. If 0, the compaction request from apiserver is disabled.
* --etcd-count-metric-poll-period duration: Default: 1m0s. Frequency of polling etcd for number of resources per type. 0 disables the metric collection.
* --etcd-keyfile string: SSL key file used to secure etcd communication.
* --etcd-prefix string: Default: "/registry". The prefix to prepend to all resource paths in etcd.
* --etcd-servers stringSlice: List of etcd servers to connect with (scheme://ip:port), comma separated.
* --etcd-servers-overrides stringSlice: Per-resource etcd servers overrides, comma separated. The individual override format: group/resource#servers, where servers are URLs, semicolon separated.
* --event-ttl duration: Default: 1h0m0s. Amount of time to retain events.
* --experimental-encryption-provider-config string: The file containing configuration for encryption providers to be used for storing secrets in etcd
* --external-hostname string: The hostname to use when generating externalized URLs for this master (e.g. Swagger API Docs).
### feature-gates
* --feature-gates mapStringBool: A set of key=value pairs that describe feature gates for alpha/experimental features. Options are:
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
* -h, --help: help for kube-apiserver
* --http2-max-streams-per-connection int: The limit that the server gives to clients for the maximum number of streams in an HTTP/2 connection. Zero means to use golang's default.
### kubelet
* --kubelet-certificate-authority string: Path to a cert file for the certificate authority.
* --kubelet-client-certificate string: Path to a client cert file for TLS.
* --kubelet-client-key string: Path to a client key file for TLS.
* --kubelet-https: Default: true. Use https for kubelet connections.
* --kubelet-preferred-address-types stringSlice: Default: [Hostname,InternalDNS,InternalIP,ExternalDNS,ExternalIP]. List of the preferred NodeAddressTypes to use for kubelet connections.
* --kubelet-timeout duration: Default: 5s. Timeout for kubelet operations.
* --kubernetes-service-node-port int: If non-zero, the Kubernetes master service (which apiserver creates/maintains) will be of type NodePort, using this as the value of the port. If zero, the Kubernetes master service will be of type ClusterIP.
* --log-flush-frequency duration: Default: 5s. Maximum number of seconds between log flushes
* --master-service-namespace string: Default: "default". DEPRECATED: the namespace from which the kubernetes master services should be injected into pods.
* --max-connection-bytes-per-sec int: If non-zero, throttle each user connection to this number of bytes/sec. Currently only applies to long-running requests.
* --max-mutating-requests-inflight int: Default: 200. The maximum number of mutating requests in flight at a given time. When the server exceeds this, it rejects requests. Zero for no limit.
* --max-requests-inflight int: Default: 400. The maximum number of non-mutating requests in flight at a given time. When the server exceeds this, it rejects requests. Zero for no limit.
* --min-request-timeout int: Default: 1800. An optional field indicating the minimum number of seconds a handler must keep a request open before timing it out. Currently only honored by the watch request handler, which picks a randomized value above this number as the connection timeout, to spread out load.
### oidc
* --oidc-ca-file string: If set, the OpenID server's certificate will be verified by one of the authorities in the oidc-ca-file, otherwise the host's root CA set will be used.
* --oidc-client-id string: The client ID for the OpenID Connect client, must be set if oidc-issuer-url is set.
* --oidc-groups-claim string: If provided, the name of a custom OpenID Connect claim for specifying user groups. The claim value is expected to be a string or array of strings. This flag is experimental, please see the authentication documentation for further details.
* --oidc-groups-prefix string: If provided, all groups will be prefixed with this value to prevent conflicts with other authentication strategies.
* --oidc-issuer-url string: The URL of the OpenID issuer, only HTTPS scheme will be accepted. If set, it will be used to verify the OIDC JSON Web Token (JWT).
* --oidc-required-claim mapStringString: A key=value pair that describes a required claim in the ID Token. If set, the claim is verified to be present in the ID Token with a matching value. Repeat this flag to specify multiple claims.
* --oidc-signing-algs stringSlice: Default: [RS256]. Comma-separated list of allowed JOSE asymmetric signing algorithms. JWTs with a 'alg' header value not in this list will be rejected. Values are defined by RFC 7518 https://tools.ietf.org/html/rfc7518#section-3.1.
* --oidc-username-claim string: Default: "sub". The OpenID claim to use as the user name. Note that claims other than the default ('sub') is not guaranteed to be unique and immutable. This flag is experimental, please see the authentication documentation for further details.
* --oidc-username-prefix string: If provided, all usernames will be prefixed with this value. If not provided, username claims other than 'email' are prefixed by the issuer URL to avoid clashes. To skip any prefixing, provide the value '-'.
### profiling
* --profiling: Default: true: Enable profiling via web interface host:port/debug/pprof/
* --proxy-client-cert-file string: Client certificate used to prove the identity of the aggregator or kube-apiserver when it must call out during a request. This includes proxying requests to a user api-server and calling out to webhook admission plugins. It is expected that this cert includes a signature from the CA in the --requestheader-client-ca-file flag. That CA is published in the 'extension-apiserver-authentication' configmap in the kube-system namespace. Components receiving calls from kube-aggregator should use that CA to perform their half of the mutual TLS verification.
* --proxy-client-key-file string: Private key for the client certificate used to prove the identity of the aggregator or kube-apiserver when it must call out during a request. This includes proxying requests to a user api-server and calling out to webhook admission plugins.
* --request-timeout duration: Default: 1m0s. An optional field indicating the duration a handler must keep a request open before timing it out. This is the default request timeout for requests but may be overridden by flags such as --min-request-timeout for specific types of requests.
* --requestheader-allowed-names stringSlice: List of client certificate common names to allow to provide usernames in headers specified by --requestheader-username-headers. If empty, any client certificate validated by the authorities in --requestheader-client-ca-file is allowed.
* --requestheader-client-ca-file string: Root certificate bundle to use to verify client certificates on incoming requests before trusting usernames in headers specified by --requestheader-username-headers. WARNING: generally do not depend on authorization being already done for incoming requests.
* --requestheader-extra-headers-prefix stringSlice: List of request header prefixes to inspect. X-Remote-Extra- is suggested.
* --requestheader-group-headers stringSlice: List of request headers to inspect for groups. X-Remote-Group is suggested.
* --requestheader-username-headers stringSlice: List of request headers to inspect for usernames. X-Remote-User is common.
* --runtime-config mapStringString: A set of key=value pairs that describe runtime configuration that may be passed to apiserver. <group>/<version> (or <version> for the core group) key can be used to turn on/off specific api versions. api/all is special key to control all api versions, be careful setting it false, unless you know what you do. api/legacy is deprecated, we will remove it in the future, so stop using it.
* --secure-port int: Default: 6443. The port on which to serve HTTPS with authentication and authorization. If 0, don't serve HTTPS at all.
* --service-account-api-audiences stringSlice: Identifiers of the API. The service account token authenticator will validate that tokens used against the API are bound to at least one of these audiences.
* --service-account-issuer string: Identifier of the service account token issuer. The issuer will assert this identifier in "iss" claim of issued tokens. This value is a string or URI.
* --service-account-key-file stringArray: File containing PEM-encoded x509 RSA or ECDSA private or public keys, used to verify ServiceAccount tokens. The specified file can contain multiple keys, and the flag can be specified multiple times with different files. If unspecified, --tls-private-key-file is used. Must be specified when --service-account-signing-key is provided
* --service-account-lookup: Default: true. If true, validate ServiceAccount tokens exist in etcd as part of authentication.
* --service-account-signing-key-file string: Path to the file that contains the current private key of the service account token issuer. The issuer will sign issued ID tokens with this private key. (Requires the 'TokenRequest' feature gate.)
* --service-cluster-ip-range ipNet: Default: 10.0.0.0/24. A CIDR notation IP range from which to assign service cluster IPs. This must not overlap with any IP ranges assigned to nodes for pods.
* --service-node-port-range portRange: Default: 30000-32767. A port range to reserve for services with NodePort visibility. Example: '30000-32767'. Inclusive at both ends of the range.
### storage
* --storage-backend string: The storage backend for persistence. Options: 'etcd3' (default), 'etcd2'.
* --storage-media-type string: Default: "application/vnd.kubernetes.protobuf". The media type to use to store objects in storage. Some resources or storage backends may only support a specific media type and will ignore this setting.
* --storage-versions string: The per-group version to store resources in. Specified in the format "group1/version1,group2/version2,...". In the case where objects are moved from one group to the other, you may specify the format "group1=group2/v1beta1,group3/v1beta1,...". You only need to pass the groups you wish to change from the defaults. It defaults to a list of preferred versions of all known groups.
    Default:"
    * admission.k8s.io/v1beta1,
    * admissionregistration.k8s.io/v1beta1,
    * apps/v1,
    * authentication.k8s.io/v1,
    * authorization.k8s.io/v1,
    * autoscaling/v1,
    * batch/v1,
    * certificates.k8s.io/v1beta1,
    * componentconfig/v1alpha1,
    * events.k8s.io/v1beta1,
    * extensions/v1beta1,
    * imagepolicy.k8s.io/v1alpha1,
    * networking.k8s.io/v1,
    * policy/v1beta1,
    * rbac.authorization.k8s.io/v1,
    * scheduling.k8s.io/v1beta1,
    * settings.k8s.io/v1alpha1,
    * storage.k8s.io/v1,
    * v1
"
* --target-ram-mb int: Memory limit for apiserver in MB (used to configure sizes of caches, etc.)
* --tls-cert-file string: File containing the default x509 Certificate for HTTPS. (CA cert, if any, concatenated after server cert). If HTTPS serving is enabled, and --tls-cert-file and --tls-private-key-file are not provided, a self-signed certificate and key are generated for the public address and saved to the directory specified by --cert-dir.
* --tls-cipher-suites stringSlice: Comma-separated list of cipher suites for the server. If omitted, the default Go cipher suites will be use. 

Possible values: TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA,TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256,TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA,TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_ECDSA_WITH_RC4_128_SHA,TLS_ECDHE_RSA_WITH_3DES_EDE_CBC_SHA,TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA,TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_RSA_WITH_RC4_128_SHA,TLS_RSA_WITH_3DES_EDE_CBC_SHA,TLS_RSA_WITH_AES_128_CBC_SHA,TLS_RSA_WITH_AES_128_CBC_SHA256,TLS_RSA_WITH_AES_128_GCM_SHA256,TLS_RSA_WITH_AES_256_CBC_SHA,TLS_RSA_WITH_AES_256_GCM_SHA384,TLS_RSA_WITH_RC4_128_SHA
* --tls-min-version string: Minimum TLS version supported. Possible values: VersionTLS10, VersionTLS11, VersionTLS12
* --tls-private-key-file string: File containing the default x509 private key matching --tls-cert-file.
* --tls-sni-cert-key namedCertKey: Default: []. A pair of x509 certificate and private key file paths, optionally suffixed with a list of domain patterns which are fully qualified domain names, possibly with prefixed wildcard segments. If no domain patterns are provided, the names of the certificate are extracted. Non-wildcard matches trump over wildcard matches, explicit domain patterns trump over extracted names. For multiple key/certificate pairs, use the --tls-sni-cert-key multiple times. Examples: "example.crt,example.key" or "foo.crt,foo.key:*.foo.com,foo.com".
* --token-auth-file string: If set, the file that will be used to secure the secure port of the API server via token authentication.
* --version version[=true]: Print version information and quit
* --watch-cache: Default: true. Enable watch caching in the apiserver
* --watch-cache-sizes stringSlice: List of watch cache sizes for every resource (pods, nodes, etc.), comma separated. The individual override format: resource[.group]#size, where resource is lowercase plural (no version), group is optional, and size is a number. It takes effect when watch-cache is enabled. Some resources (replicationcontrollers, endpoints, nodes, pods, services, apiservices.apiregistration.k8s.io) have system defaults set by heuristics, others default to default-watch-cache-size