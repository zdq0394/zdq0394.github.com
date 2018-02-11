# Managing Service Accounts
## User accounts VS Service accounts
Kubernetes对User accounts和Service accounts两个概念做了区分：
* User accounts是人使用的。Service accounts是pod中的进程使用的。
* User accounts是全局的，名字必须在整个集群所有的空间都唯一，以后`用户资源`将不区分namespace。Service account的作用范围在namespace内。
* User account的创建是重量的；Service account的创建是轻量的。
* 对User account和Service account的审计时不同的。

## Service account automation
Service account的自动化操作由3个组件合作完成：
* a Service Account Admission Controller
* a Token Controller
* a Service Account Controller

### Service Account Admission Controller
Service account admission controller（简称SAAC）是API Server的一部分。
当Pod创建/更新的时候，SAAC同步的对pods进行修改，基本步骤如下：
1. 如果Pod没有ServiceAccount， SAAC设置为default的service account，一般是`default`。
2. 确保Pod引用的service account存在，否则拒绝这次请求。
3. 如果Pod没有ImagePullSecrets，则将service account的ImagePullSecrets加入到Pod中。
4. 将一个volume加入到Pod中，volume中包含访问API的token
5. 为Pod中的每一个容器添加一个volumeSource，挂载路径：/var/run/secrets/kubernetes.io/serviceaccount。

### Token Controller
Token Controller是controller-manager的一部分。
Token Controller异步执行。
* 观察serviceAccount的创建，当有新的serviceAccount创建的时候，创建一个与之相关的访问API Server的secret。
* 观察serviceAccount的删除，删掉所有相关的ServiceAccountToken secrets。
* 观察secret的添加，确保关联的service account存在。如果需要，添加一个token到secret中。
* 观察secret的删除，如果需要的化，从相关的service account中清除对secret的引用。

启动controller-manager时，通过--service-account-private-key-file指定一个private key file给token controller。这个private key file用来对生成的service account token签名。同样，启动apiserver时，通过 --service-account-key-file指定public key，用来验证token controller颁发的token。

### Service Account Controller
Service Account Controller管理namespaces中的ServiceAccount。确保在每个namespaces中存在一个名为`default`的ServiceAccount。
