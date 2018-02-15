# User Impersonation
通过`impersonation headers`，一个用户可以扮演另一个用户去操作资源，使得一个请求可以修改请求认证的user info。比如，admin使用这个功能调试授权策略：临时impersonating一个user看是否通过授权。

`Impersonation requests`首先认证为`requesting user`，然后切换到`impersonated user`的信息。
* 用户使用**自己的认证凭证（credentials）**和**impersonation headers**调用API。
* API Server认证请求。
* API Server检查authenticated user是否具有`impersonation`权限。
* Request User info被替换为impersonated值。
* Request被验证通过，authorization模块基于impersonated user info进行授权。

Impersonation Headers：
* Impersonate-User
* Impersonate-Group
* Impersonate-Extra-(EXTRANAME)

```ini
Impersonate-User: jane.doe@example.com
Impersonate-Group: developers
Impersonate-Group: admins
Impersonate-Extra-dn: cn=jane,ou=engineers,dc=example,dc=com
Impersonate-Extra-scopes: view
Impersonate-Extra-scopes: development
```

使用`kubectl`命令时，可以通过`--as` flag配置`Impersonate-User`首部，通过`--as-group` flag配置`Impersonate-Group`首部。

```sh
$ kubectl drain mynode
Error from server (Forbidden): User "clark" cannot get nodes at the cluster scope. (get nodes mynode)

$ kubectl drain mynode --as=superman --as-group=system:masters
node "mynode" cordoned
node "mynode" drained
```
要impersonate一个user/group或者设置extra字段，`Impersonating User`在`Impersonated Attributes`上具有`Impersonate`的权限。
比如：
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: impersonator
rules:
- apiGroups: [""]
  resources: ["users", "groups", "serviceaccounts"]
  verbs: ["impersonate"]
```

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: scopes-impersonator
rules:
# Can set "Impersonate-Extra-scopes" header.
- apiGroups: ["authentication.k8s.io"]
  resources: ["userextras/scopes"]
  verbs: ["impersonate"]
```

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: limited-impersonator
rules:
# Can impersonate the user "jane.doe@example.com"
- apiGroups: [""]
  resources: ["users"]
  verbs: ["impersonate"]
  resourceNames: ["jane.doe@example.com"]

# Can impersonate the groups "developers" and "admins"
- apiGroups: [""]
  resources: ["groups"]
  verbs: ["impersonate"]
  resourceNames: ["developers","admins"]

# Can impersonate the extras field "scopes" with the values "view" and "development"
- apiGroups: ["authentication.k8s.io"]
  resources: ["userextras/scopes"]
  verbs: ["impersonate"]
  resourceNames: ["view", "development"]
```




