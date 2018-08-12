# Kubernetes的证书认证
## Kubernetes各组件的证书配置
### API Server
* --cert-dir string                           The directory where the TLS certs are located. If --tls-cert-file and --tls-private-key-file are provided, this flag will be ignored. (default "/var/run/kubernetes")
* --client-ca-file string                     If set, any request presenting a client certificate signed by one of the authorities in the client-ca-file is authenticated with an identity corresponding to the CommonName of the client certificate.
* --etcd-certfile string                      SSL certification file used to secure etcd communication.
* --etcd-keyfile string                       SSL key file used to secure etcd communication.
* --kubelet-certificate-authority string      Path to a cert file for the certificate authority.
* --kubelet-client-certificate string         Path to a client cert file for TLS.
* --kubelet-client-key string                 Path to a client key file for TLS.
* --proxy-client-cert-file string             Client certificate used to prove the identity of the aggregator or kube-apiserver when it must call out during a request. This includes proxying requests to a user api-server and calling out to webhook admission plugins. It is expected that this cert includes a signature from the CA in the --requestheader-client-ca-file flag. That CA is published in the 'extension-apiserver-authentication' configmap in the kube-system namespace. Components recieving calls from kube-aggregator should use that CA to perform their half of the mutual TLS verification.
* --proxy-client-key-file string              Private key for the client certificate used to prove the identity of the aggregator or kube-apiserver when it must call out during a request. This includes proxying requests to a user api-server and calling out to webhook admission plugins.
* --requestheader-allowed-names stringSlice   List of client certificate common names to allow to provide usernames in headers specified by --requestheader-username-headers. If empty, any client certificate validated by the authorities in --requestheader-client-ca-file is allowed.
* --requestheader-client-ca-file string       Root certificate bundle to use to verify client certificates on incoming requests before trusting usernames in headers specified by --requestheader-username-headers
* --service-account-key-file stringArray      File containing PEM-encoded x509 RSA or ECDSA private or public keys, used to verify ServiceAccount tokens. If unspecified, --tls-private-key-file is used. The specified file can contain multiple keys, and the flag can be specified multiple times with different files.
* --ssh-keyfile string                        If non-empty, use secure SSH proxy to the nodes, using this user keyfile
* --tls-ca-file string                        If set, this certificate authority will used for secure access from Admission Controllers. This must be a valid PEM-encoded CA bundle. Alternatively, the certificate authority can be appended to the certificate provided by --tls-cert-file.
* --tls-cert-file string                      File containing the default x509 Certificate for HTTPS. (CA cert, if any, concatenated after server cert). If HTTPS serving is enabled, and --tls-cert-file and --tls-private-key-file are not provided, a self-signed certificate and key are generated for the public address and saved to /var/run/kubernetes.
* --tls-private-key-file string               File containing the default x509 private key matching --tls-cert-file.
* --tls-sni-cert-key namedCertKey             A pair of x509 certificate and private key file paths, optionally suffixed with a list of domain patterns which are fully qualified domain names, possibly with prefixed wildcard segments. If no domain patterns are provided, the names of the certificate are extracted. Non-wildcard matches trump over wildcard matches, explicit domain patterns trump over extracted names. For multiple key/certificate pairs, use the --tls-sni-cert-key multiple times. Examples: "example.crt,example.key" or "foo.crt,foo.key:*.foo.com,foo.com". (default [])

### Controller Manager
* --cluster-signing-cert-file string          Filename containing a PEM-encoded X509 CA certificate used to issue cluster-scoped certificates (default "/etc/kubernetes/ca/ca.pem")
* --cluster-signing-key-file string           Filename containing a PEM-encoded RSA or ECDSA private key used to sign cluster-scoped certificates (default "/etc/kubernetes/ca/ca.key")
* --root-ca-file string                       If set, this root certificate authority will be included in service account's token secret. This must be a valid PEM-encoded CA bundle.
* --service-account-private-key-file string   Filename containing a PEM-encoded private RSA or ECDSA key used to sign service account tokens.

### Kubelet
* --client-ca-file string                   If set, any request presenting a client certificate signed by one of the authorities in the client-ca-file is authenticated with an identity corresponding to the CommonName of the client certificate.
* --tls-cert-file string                    File containing x509 Certificate used for serving HTTPS (with intermediate certs, if any, concatenated after server cert). If --tls-cert-file and --tls-private-key-file are not provided, a self-signed certificate and key are generated for the public address and saved to the directory passed to --cert-dir.
* --tls-private-key-file string             File containing x509 private key matching --tls-cert-file.

