# Managing Service Accounts
## User accounts VS Service accounts
Kubernetes对User accounts和Service accounts做了区分：
* User accounts是人使用的；Service accounts是由进程使用的，Pod中的容器中的进程。
* User accounts是**全局**的，名字必须在整个集群所有的namespaces都唯一，以后`用户资源`将不区分namespace；Service account的作用范围在**namespace**内。
* User account的创建是重量的，一般都是和公司的帐号系统结成的，和公司的业务流程结合在一起；Service account的创建是轻量的。
* 对User account和Service account的审计是不同的。

## Service account automation
Service account的自动化由3个组件合作完成：
* Service Account Admission Controller
* Token Controller
* Service Account Controller

### Service Account Admission Controller
Service account admission controller（简称SAAC）是API Server的一部分。
当Pod创建/更新的时候，SAAC同步的对pods进行修改，基本步骤如下：
1. 如果Pod没有设置ServiceAccount， SAAC为该Pod设置默认的service account，一般是`default`。
2. 如果Pod设置有ServiceAccount，SAAC确保Pod引用的service account存在，否则拒绝这次请求。
3. 如果Pod没有设置ImagePullSecrets，SAAC将service account的ImagePullSecrets加入到Pod中。
4. SAAC将一个volume加入到Pod中，volume中包含访问API的token，token是配置的service account对应的token。
5. SAAC为Pod中的每一个容器添加一个volumeSource，挂载路径：/var/run/secrets/kubernetes.io/serviceaccount。

### Token Controller
Token Controller是controller-manager的一部分。
Token Controller异步执行。
* 观察serviceAccount的创建，当有新的ServiceAccount创建的时候，创建一个与之相关的访问API Server的secret。
* 观察serviceAccount的删除，当一个ServiceAccount被删除的时候，删掉与之相关的所有ServiceAccountToken secrets。
* 观察secret的添加，确保关联的service account存在。如果需要，添加一个token到secret中。
* 观察secret的删除，如果需要的化，从相关的service account中清除对secret的引用。

**重点**
启动controller-manager时，通过`--service-account-private-key-file`指定一个private key file给token controller。
这个private key file用来对生成的service account token签名。

启动apiserver时，通过`--service-account-key-file`指定public key，用来验证token controller颁发的token是否有效。

**为Service Account另外创建api token**
一个**controller loop**确保么每个service account都存在一个API token。

要为某个service account新创建一个API token，首先，创建一个`ServiceAccountToken`类型的secret，并且在该secret中通过`annotation`的方式引用`service account`。
**controller loop**将自动更新。

```yaml
{
    "kind": "Secret",
    "apiVersion": "v1",
    "metadata": {
        "name": "mysecretname",
        "annotations": {
            "kubernetes.io/service-account.name": "myserviceaccount"
        }
    },
    "type": "kubernetes.io/service-account-token"
}
```

**Delete/Invalidate 一个service account token**
将相关的secret删除即可。
```sh
kubectl delete secret mysecretname
```

### Service Account Controller
Service Account Controller管理namespaces中的ServiceAccount。
确保在每个namespaces中存在一个名为`default`的ServiceAccount。
