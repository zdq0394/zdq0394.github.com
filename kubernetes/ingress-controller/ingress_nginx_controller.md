# Ingress Nginx Controller
## 概述
## 部署
K8S官方提供了部署ingress-nginx-controller的：[yaml配置](https://github.com/kubernetes/ingress-nginx/blob/master/deploy/mandatory.yaml)。
可以执行如下命令：
```sh
kubectl create -f https://github.com/kubernetes/ingress-nginx/blob/master/deploy/mandatory.yaml
```
此时，Ingress-Nginx-Controller的deployment已经部署好。

通过部署NodePort服务把ingress-nginx-controller暴露出来。
```yaml
---
apiVersion: v1
kind: Service
metadata:
  name: ingress-nginx
  namespace: ingress-nginx
  labels:
    app: ingress-nginx

spec:
  type: NodePort
  ports:
  - port: 80
    nodePort: 11080
    name: http
  - port: 443
    nodePort: 11443
    name: https
  selector:
    app: ingress-nginx
```
