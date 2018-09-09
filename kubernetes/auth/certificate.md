# Kubernetes的证书认证
## Kubernetes各组件的证书配置
### API Server
* --cert-dir string：存放TLS证书的目录，默认值是`/var/run/kubernetes`。如果配置了参数`--tls-cert-file`和`--tls-private-key-file`，那么`--cert-dir`参数被忽略。
* --tls-cert-file string：APIServer提供https服务时使用的x509证书。如果APIServer开启了HTTPS，并且`--tls-cert-file`和`--tls-private-key-file`没有配置，APIServer会生成一个自签名`self-signed`的证书，并保存在`--cert-dir`指定的目录下（默认是`/var/run/kubernetes`）。
* --tls-private-key-file string：和`--tls-cert-file`指定的x509证书匹配的私钥。

* --client-ca-file string：当APIServer开启证书认证时，用来认证客户端证书合法性的CA列表。`--client-ca-file`可以包含多个CA。
* --kubelet-certificate-authority string：当kubelet开启HTTP时，APIServer用来认证kubelet的证书合法性的CA。
* --kubelet-client-certificate string：Path to a client cert file for TLS。
* --kubelet-client-key string：Path to a client key file for TLS。

* --service-account-key-file stringArray：`serviceacccount`认证时的公钥，用来验证serviceaccount的token是否合法。

### Controller Manager
* --cluster-signing-cert-file string： Filename containing a PEM-encoded X509 CA certificate used to issue cluster-scoped certificates (default "/etc/kubernetes/ca/ca.pem")
* --cluster-signing-key-file string：Filename containing a PEM-encoded RSA or ECDSA private key used to sign cluster-scoped certificates (default "/etc/kubernetes/ca/ca.key")
* --root-ca-file string：如果设置，该`根证书`将会包含在service account的token secret中。
* --service-account-private-key-file string：用来签署serviceaccount的token的私钥。

### Kubelet
* --client-ca-file string：当kubelet开启`证书认证`时，用该文件中指定的CA来认证客户端提供的证书的合法性。
* --tls-cert-file string：当kubelet开启HTTPS服务时使用的x509证书。 如果`--tls-cert-file`和`--tls-private-key-file`没有提供，会自动生成一个自签发的证书存放在`--cert-dir`指定的目录中。
* --tls-private-key-file string：当kubelet开启HTTPS服务时，使用的x509证书对应的私钥。

## 基本概念
### CA
CA的职责就是签发证书，并告诉用户“这个证书是我发的，证书中的公钥证正是证书中的服务（IP地址）所有的，不是假冒的。我可以作证。”。
那问题来了，这个CA是否可信呢？谁来认证这个CA是否可信呢？

CA自己也有一个`证书`来认证自己，这个`证书`不能是自己签发的。这个证书是由“上一级”`CA`签发的。如此迭代下来，最终会有一个“根证书”——不需要其他机构背书，客户无条件相信的证书——CA的证书。有其他使用TLS的系统（非kubernetes）都会去本机系统`/etc/ssl`中 查找一个本机信任的CA列表，但是Kubernetes不是，必须显式的进行告知签发CA。

