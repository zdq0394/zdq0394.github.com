# Kubelet
## Kubelet概述
Kubelet运行在每个node上。
Kubelet保持一个**PodSpecs**的集合，并确保PodSpecs描述的containers一直运行并且是健康的。
那些非Kubernetes创建的容器，kubelet不管理。

Kubelet的PodSpecs来自于：
* **apiserver**
* file
* http endpoint
* http server

## kubelet options
* --address ip：Kubelet监听的IP地址，默认是`0.0.0.0`，监听所有的接口。
* --port int32：Kubelet监听的端口。
* --allow-privileged：如果设置为true，允许容器请求`privileged`模式。
* --anonymous-auth：允许匿名请求访问Kubelet server，默认是true。
* --bootstrap-kubeconfig string：                                                                             Path to a kubeconfig file that will be used to get client certificate for kubelet. If the file specified by --kubeconfig does not exist, the bootstrap kubeconfig is used to request a client certificate from the API server. On success, a kubeconfig file referencing the generated client certificate and key is written to the path specified by --kubeconfig. The client certificate and key file will be stored in the directory pointed by --cert-dir.
* --cadvisor-port int32：默认是4194。
* --cert-dir string：如果kubelet server开启https服务，该目录存放tls证书。如果设置了`--tls-cert-file`和`--tls-private-key-file`，该字段被忽略，默认是"/var/lib/kubelet/pki"。
* --cgroup-driver string：Kubelet用来操纵host上的cgroups的driver：'cgroupfs'和'systemd'，默认是"cgroupfs"。
* --cgroup-root string：pods使用的root cgroup，可选值。
* --client-ca-file string                                                                                     If set, any request presenting a client certificate signed by one of the authorities in the client-ca-file is authenticated with an identity corresponding to the CommonName of the client certificate.
* --cluster-dns stringSlice                                                                                   Comma-separated list of DNS server IP address.  This value is used for containers DNS server in case of Pods with "dnsPolicy=ClusterFirst". Note: all DNS servers appearing in the list MUST serve the same set of records otherwise name resolution within the cluster may not work correctly. There is no guarantee as to which DNS server may be contacted for name resolution.
 * --cluster-domain string                                                                                     Domain for this cluster.  If set, kubelet will configure all containers to search this domain in addition to the host's search domains
 * --cni-bin-dir string                                                                                        <Warning: Alpha feature> The full path of the directory in which to search for CNI plugin binaries. Default: /opt/cni/bin
 * --cni-conf-dir string                                                                                       <Warning: Alpha feature> The full path of the directory in which to search for CNI config files. Default: /etc/cni/net.d
* --container-runtime string                                                                                  The container runtime to use. Possible values: 'docker', 'rkt'. (default "docker")
 * --container-runtime-endpoint string                                                                         [Experimental] The endpoint of remote runtime service. Currently unix socket is supported on Linux, and tcp is supported on windows.  Examples:'unix:///var/run/dockershim.sock', 'tcp://localhost:3735' (default "unix:///var/run/dockershim.sock")
* --enable-server：开启kubelet server，默认true。
* --healthz-bind-address ip：The IP address for the healthz server to serve on. (set to 0.0.0.0 for all interfaces) (default 127.0.0.1)
* --healthz-port int32：The port of the localhost healthz endpoint (set to 0 to disable) (default 10248)
* --hostname-override string：If non-empty, will use this string as identification instead of the actual hostname.
* --http-check-frequency duration：Duration between checking http for new data (default 20s)
* --iptables-drop-bit int32：The bit of the fwmark space to mark packets for dropping. Must be within the range [0, 31]. (default 15)
* --iptables-masquerade-bit int32：The bit of the fwmark space to mark packets for SNAT. Must be within the range [0, 31]. Please match this parameter with corresponding parameter in kube-proxy. (default 14)
* --kubeconfig string：访问kube-apiserver的配置，默认是：/var/lib/kubelet/kubeconfig。
* --kubelet-cgroups string：Optional absolute name of cgroups to create and run the Kubelet in.
* --max-pods int32：该Kubelet可以创建的最大的pod数目，默认是110个。
* --network-plugin string：<Warning: Alpha feature> The name of the network plugin to be invoked for various events in kubelet/pod lifecycle
* --network-plugin-mtu int32：<Warning: Alpha feature> The MTU to be passed to the network plugin, to override the default. Set to 0 to use the default 1460 MTU.
* --node-ip string：IP address of the node. If set, kubelet will use this IP address for the node
* --node-labels mapStringString：<Warning: Alpha feature> Labels to add when registering the node in the cluster.  Labels must be key=value pairs separated by ','.
* --node-status-update-frequency duration：Specifies how often kubelet posts node status to master. Note: be cautious when changing the constant, it must work with nodeMonitorGracePeriod in nodecontroller. (default 10s)
* --pod-cidr string：The CIDR to use for pod IP addresses, only used in standalone mode.  In cluster mode, this is obtained from the master.
* --pod-infra-container-image string：The image whose network/ipc namespaces containers in each pod will use. (default "k8s.gcr.io/pause-amd64:3.0")
* --read-only-port int32：The read-only port for the Kubelet to serve on with no authentication/authorization (set to 0 to disable) (default 10255)
* --resolv-conf string：Resolver configuration file used as the basis for the container DNS resolution configuration. (default "/etc/resolv.conf")
* --root-dir string：Directory path for managing kubelet files (volume mounts,etc). (default "/var/lib/kubelet")
* --runtime-cgroups string：Optional absolute name of cgroups to create and run the runtime in.
* --system-cgroups /：Optional absolute name of cgroups in which to place all non-kernel processes that are not already inside a cgroup under /. Empty for no container. Rolling back the flag requires a reboot.
* --system-reserved mapStringString：A set of ResourceName=ResourceQuantity (e.g. cpu=200m,memory=500Mi,ephemeral-storage=1Gi) pairs that describe resources reserved for non-kubernetes components. Currently only cpu and memory are supported. See http://kubernetes.io/docs/user-guide/compute-resources for more detail. [default=none]
* --system-reserved-cgroup string：Absolute name of the top level cgroup that is used to manage non-kubernetes components for which compute resources were reserved via '--system-reserved' flag. Ex. '/system-reserved'. [default='']
* --tls-cert-file string：File containing x509 Certificate used for serving HTTPS (with intermediate certs, if any, concatenated after server cert). If --tls-cert-file and --tls-private-key-file are not provided, a self-signed certificate and key are generated for the public address and saved to the directory passed to --cert-dir.
* --tls-private-key-file string：File containing x509 private key matching --tls-cert-file.
* --version version[=true]：Print version information and quit