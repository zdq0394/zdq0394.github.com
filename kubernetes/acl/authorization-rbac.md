# 使用RBAC授权
Role-Based Access Control("RBAC")，基于角色的访问控制使用API Group **rbac.authorization.k8s.io**驱动授权决定：允许管理员admin通过kubernetes API动态的配置策略（policy）。

如果要开启RBAC，启动API Server时，加上flag：**--authorization-mode=RBAC**。

## API概述
**RBAC API**声明了4种top-level的资源类型。
用户可以使用这四种资源，像使用其它API资源一样，比如通过kubectl，API调用等。

### Role和ClusterRole
在RBAC API中，一个角色（role）包含了一系列的规则（rules），这些规则（rules）表示一个权限的集合。
权限是加成的（additive），即所有规则都是“许可”，没有“拒绝”。

* 可以使用资源类型`Role`来定义一个`namespace`作用域的角色。
* 可以使用资源类型`ClusterRole`来定义一个`cluster`作用域的角色。

```yaml
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  namespace: default
  name: pod-reader
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "watch", "list"]
```

```yaml
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: secret-reader
rules:
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get", "watch", "list"]
```

### RoleBinding和ClusterRoleBinding
一个角色(role)绑定(binding)（RoleBinding/ClusterRoleBinding）将角色(role)中定义的权限(permissions)授权给一个或者多个用户(user)。
一个角色(role)绑定(binding)包含一个主体集合（users，groups，services accounts），并引用一个角色。

RoleBinding可以引用同一个namespace中的Role:
```yaml
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  namespace: default
  name: read-pods
subjects:
- kind: User
  name: jane
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

RoleBinding也可以引用一个ClusterRole，将ClusterRole中定义的某些资源的访问权限限定到RoleBinding中的namespace，然后授权给users。
```yaml
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  namespace: development
  name: read-secrets
subjects:
- kind: User
  apiGroup: rbac.authorization.k8s.io
  name: dave
roleRef:
  kind: ClusterRole
  name: secret-reader
  apiGroup: rbac.authorization.k8s.io
```

ClusterRoleBinding用来授权Cluster范围的资源。
```yaml
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: read-secrets-global
subjects:
- kind: Group
  name: manager
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: secret-reader
  apiGroup: rbac.authorization.k8s.io
```

### Referring to Resources
**子资源**

```yaml
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  namespace: default
  name: pod-and-pod-logs-reader
rules:
- apiGroups: [""]
  resources: ["pods", "pods/log"]
  verbs: ["get", "list"]
```

**resourceNames**
可以通过resourceNames，指定具体的资源名字，而不仅仅是资源类型。

```yaml
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  namespace: default
  name: ddd
rules:
- apiGroups: [""]
  resources: ["configmaps"]
  resourceNames: ["my-configmap"]
  verbs: ["update", "get"]
```

注意，如果指定了resourceNames，那verbs不能包含：watch, list, create, deletecollection。

### Role例子
1. 允许读"core api group"下的"pods"
``` yaml
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "watch", "list"]
```

2. 允许reading/writing “deployments” in both the “extensions” and “apps” API groups:
``` yaml
rules:
- apiGroups: ["apps", "extensions"]
  resources: ["deployments"]
  verbs: ["get", "watch", "list", "update", "create", "delete", "patch"]
```

3. 允许 reading “pods” and reading/writing “jobs”:
```yaml
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "watch", "list"]
- apiGroups: ["batch", "extensions"]
  resources: ["jobs"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]

4. 允许reading a ConfigMap named “my-config” (must be bound with a RoleBinding to limit to a single ConfigMap in a single namespace):
```yaml
rules:
- apiGroups: [""]
  resources: ["configmaps"]
  resourceNames: ["my-config"]
  verbs: ["get"]
```

5. 允许 reading the resource “nodes” in the core group (because a Node is cluster-scoped, this must be in a ClusterRole bound with a ClusterRoleBinding to be effective):
```yaml
rules:
- apiGroups: [""]
  resources: ["nodes"]
  verbs: ["get", "list", "watch"]
```

6. 允许 “GET” and “POST” requests to the non-resource endpoint “/healthz” and all subpaths (must be in a ClusterRole bound with a ClusterRoleBinding to be effective):
```yaml
rules:
- nonResourceURLs: ["/healthz", "/healthz/*"]
  verbs: ["get", "post"]

### Referring to Subjects
RoleBinding或者ClusterRoleBinding把一个role绑定到subjects上面。
Subjects可以是user，group或者service account。

1. 名为"alice@example.com"的user:
```yaml
subjects:
- kind: User
  name: "alice@example.com"
  apiGroup: rbac.authorization.k8s.io
```

2. 名为"frontend-admins"的group:
```yaml
subjects:
- kind: Group
  name: "frontend-admins"
  apiGroup: rbac.authorization.k8s.io
```

3. namespace "kube-system""中的service account "default":
```yaml
subjects:
- kind: ServiceAccount
  name: default
  namespace: kube-system
```

4. namespace "qa"中的所有service accounts:
```yaml
subjects:
- kind: Group
  name: system:serviceaccounts:qa
  apiGroup: rbac.authorization.k8s.io
```

5. 所有的service accounts:
```yaml
subjects:
- kind: Group
  name: system:serviceaccounts
  apiGroup: rbac.authorization.k8s.io
```

6. 所有authenticated的user:
```yaml
subjects:
- kind: Group
  name: system:authenticated
  apiGroup: rbac.authorization.k8s.io
```

7. 所有unauthenticated的users:
```yaml
subjects:
- kind: Group
  name: system:unauthenticated
  apiGroup: rbac.authorization.k8s.io
```

8. 所有的users:
```yaml
subjects:
- kind: Group
  name: system:authenticated
  apiGroup: rbac.authorization.k8s.io
- kind: Group
  name: system:unauthenticated
  apiGroup: rbac.authorization.k8s.io
```