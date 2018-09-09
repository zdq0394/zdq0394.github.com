# 使用ABAC授权
Attribute-based access control，基于属性的访问控制（ABAC），顾名思义，是这样一种访问控制机制：根据策略文件对用户进行访问控制，而策略文件由属性的集合组成。
## Policy File Format
需要指定授权策略文件：`--authorization-policy-file=SOME_FILENAME`。
文件格式是**One JSON Object Per Line**。
每一行都是一个**Policy Object**。
一个**Policy Object**包含以下属性：
### Version属性
* apiVersion：abac.authorization.kubernetes.io/v1beta1
* kind：Policy
### spec属性
* user
* group

* apiGroup
* namespace
* resource
* noResourcePath

* readonly

## 授权算法

## 示例
1. Alice可以对所有资源做任何事情：
{"apiVersion": "abac.authorization.kubernetes.io/v1beta1", "kind": "Policy", "spec": {"user": "alice", "namespace": "*", "resource": "*", "apiGroup": "*"}}
2. Kubelet可以读所有的Pods：
{"apiVersion": "abac.authorization.kubernetes.io/v1beta1", "kind": "Policy", "spec": {"user": "kubelet", "namespace": "*", "resource": "pods", "readonly": true}}
3. Kubelet可以读/写Events：
{"apiVersion": "abac.authorization.kubernetes.io/v1beta1", "kind": "Policy", "spec": {"user": "kubelet", "namespace": "*", "resource": "events"}}
4. Bob可以读namespace**projectCaribou**中的pods：
{"apiVersion": "abac.authorization.kubernetes.io/v1beta1", "kind": "Policy", "spec": {"user": "bob", "namespace": "projectCaribou", "resource": "pods", "readonly": true}}
5. 任何人可以对所有的**no-resource paths**进行只读请求：
{"apiVersion": "abac.authorization.kubernetes.io/v1beta1", "kind": "Policy", "spec": {"group": "system:authenticated", "readonly": true, "nonResourcePath": "*"}}
{"apiVersion": "abac.authorization.kubernetes.io/v1beta1", "kind": "Policy", "spec": {"group": "system:unauthenticated", "readonly": true, "nonResourcePath": "*"}}

[更多示例](https://github.com/kubernetes/kubernetes/blob/master/pkg/auth/authorizer/abac/example_policy_file.jsonl)

如果要给namespace **kube-system**中的service account **default**对API访问的所有权限，需要把下面一行加入policy文件。
{"apiVersion":"abac.authorization.kubernetes.io/v1beta1","kind":"Policy","spec":{"user":"system:serviceaccount:kube-system:default","namespace":"*","resource":"*","apiGroup":"*"}}