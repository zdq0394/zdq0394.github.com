# Kubeadm证书续期
## 查看kubernetes中所有证书的过期时间
* kubeadm alpha certs check-expiration

通过openssl查看ca证书过期时间
* openssl x509 -in /etc/kubernetes/pki/ca.crt -noout -text |grep Not

通过openssl查看apiserver证书过期时间
* openssl x509 -in /etc/kubernetes/pki/apiserver.crt -noout -text |grep ' Not '

## 证书续期
(1) 备份证书
cp -rp /etc/kubernetes /etc/kubernetes.bak

(2) 获取kubernetes集群初始化配置文件
kubeadm config view > kubeadm.yaml

(3) 生成新的证书文件
kubeadm alpha certs renew all --config=kubeadm.yaml
