# 容器流量限制
## CNI Plugin
启用流量整形支持:
1. 将bandwidth插件添加到CNI配置文件(默认是/etc/cni/net.d下面)
2. 保证可执行文件bandwidth包含在CNI的bin文件夹内(默认为/opt/cni/bin)

```json
{
  "name": "k8s-pod-network",
  "cniVersion": "0.3.0",
  "plugins": [
    {
      "type": "calico",
      "log_level": "info",
      "datastore_type": "kubernetes",
      "nodename": "127.0.0.1",
      "ipam": {
        "type": "host-local",
        "subnet": "usePodCidr"
      },
      "policy": {
        "type": "k8s"
      },
      "kubernetes": {
        "kubeconfig": "/etc/cni/net.d/calico-kubeconfig"
      }
    },
    {
      "type": "bandwidth",
      "capabilities": {"bandwidth": true}
    }
  ]
}
```

## 应用
将`kubernetes.io/ingress-bandwidth`和`kubernetes.io/egress-bandwidth`注解添加到pod层面中。
```json
apiVersion: v1
kind: Pod
metadata:
  annotations:
    kubernetes.io/ingress-bandwidth: 1M
    kubernetes.io/egress-bandwidth: 1M
```
