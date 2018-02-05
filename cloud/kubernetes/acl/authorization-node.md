# 使用Node授权
Node授权模式是一个专用授权：只针对kubelet发出的请求授权。
## 概述
Node authorizer允许kubelet执行API request，这些request包括：
### Read Operations
* services
* endpoints
* nodes
* pods
* secrets, configmaps, persistent volume claims and persistent volumes related to pods bound to the kubelet's node

### Write Operations
* nodes and node status
* pods and pod status
* events

### Auth-related Operations
* read/write access to the certificationsigningrequests API for TLS bootstrapping
* the ability to create tokenreviews and subjectaccessreviews for delegated authentication/authorization checks

### kubelet
Kubelets必须使用一个credential，这个credential认证它们为**system:node** group下面，并且具有名字**system:node:<nodeName>**。

