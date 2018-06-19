# Configure Service Accounts for Pods
**Service Account**为**Pod中运行的进程**提供身份信息（identity），以用来在访问API Server时做认证使用。

* 当人（human user）通过**kubectl**命令访问Kubernetes集群时，会被API Server认证为一个**User Account**，对于典型的kubernetes集群，通常是`admin`。
* Pods中容器的进程也可以和API Server交互，进程也会被认证为一个特殊的**Service Account**，对于典型的kubernetes集群，通常是`default`。

## Use the Default Service Account to access the API Server
当你创建一个Pod时，如果没有指定service account，Kubernetes会自动为该Pod分配当前namesapce的service account：`default`。
所谓当前namespace，就是Pod所属的namespace。
通过命令`kubectl get pods/podName -o yaml`，可以发现，`spec.serviceAccount`和`spec.serviceAccountName`都被指定为`default`。
```json
spec:
  containers:
  - command:
    - sleep
    - "3600"
    image: busybox
    imagePullPolicy: IfNotPresent
    name: busybox
    resources: {}
    terminationMessagePath: /dev/termination-log
    terminationMessagePolicy: File
    volumeMounts:
    - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
      name: default-token-5gwvj
      readOnly: true
  dnsPolicy: ClusterFirst
  nodeName: minikube
  restartPolicy: Always
  schedulerName: default-scheduler
  securityContext: {}
  serviceAccount: default
  serviceAccountName: default
  terminationGracePeriodSeconds: 30
  volumes:
  - name: default-token-5gwvj
    secret:
      defaultMode: 420
      secretName: default-token-5gwvj
```

**每个namespace都有一个`default` service account**

**每个namespace都有一个default的secret，type是： `kubernetes.io/service-account-token`。**

Pod内的进程可以使用自动挂载的service account的credentials去访问API Server。

每个Pod都包含一个目录`/var/run/secrets/kubernetes.io/serviceaccount`，目录下包含三个文件
* token
* ca.crt
* namespace

一个Service Account允许访问的资源（它的permission）取决于kubernetes的authorization机制。

1）service account可以指定`automountServiceAccountToken: false`，**不**自动挂载service account的API credentials
```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: build-robot
automountServiceAccountToken: false
...
```
2）也可以在创建pod时指定`automountServiceAccountToken: false`，**不**自动挂载该service account的API credentials
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  serviceAccountName: build-robot
  automountServiceAccountToken: false
  ...
```

2)pod配置的方式的优先级优于1)serviceaccount的方式。

## Use Multiple Service Accounts
每个namespace都有一个默认的service account resource：`default`。
可以如下列出当前namespace下的所有的service accounts：

``` sh
$ kubectl get serviceAccounts
NAME      SECRETS    AGE
default   1          1d
```

可以通过如下方式再创建一个service account：
```sh
$ cat > /tmp/serviceaccount.yaml <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: build-robot
EOF
$ kubectl create -f /tmp/serviceaccount.yaml
serviceaccount "build-robot" created
```

**每当一个新的service account创建后，会自动创建一个与之相关的token secret**。
```yaml
$ kubectl get serviceaccounts/build-robot -o yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  creationTimestamp: 2015-06-16T00:12:59Z
  name: build-robot
  namespace: default
  resourceVersion: "272500"
  selfLink: /api/v1/namespaces/default/serviceaccounts/build-robot
  uid: 721ab723-13bc-11e5-aec2-42010af0021e
secrets:
- name: build-robot-token-bvbk5
```
可以发现，build-robot已经创建并引用了secret `build-robot-token-bvbk5`。

当创建Pod时，可以通过`spec.serviceAccountName`来指定Pod要使用的service account。
创建Pod时，指定的service account必须已经存在。

## Manually create a service account API token
可以为某个service account手工创建secrets：
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: build-robot-secret
  annotations:
    kubernetes.io/service-account.name: build-robot
type: kubernetes.io/service-account-token
```
该方式会为service account `build-robot`创建一个token。

任何每个关联到service account的`secret`都会被`token cleaner`删除。
## Add ImagePullSecrets to a service account
1）创建一个ImagePullSecrets：`myregistrykey`。
2）修改namespace下的`default` service account的配置。
2.1）
```sh
kubectl patch serviceaccount default -p '{\"imagePullSecrets\": [{\"name\": \"acrkey\"}]}'
```
2.2）
2.2.1）
```sh
$ kubectl get serviceaccounts default -o yaml > ./sa.yaml
```
2.2.2）
```sh
$ cat sa.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  creationTimestamp: 2015-08-07T22:02:39Z
  name: default
  namespace: default
  resourceVersion: "243024"
  selfLink: /api/v1/namespaces/default/serviceaccounts/default
  uid: 052fb0f4-3d50-11e5-b066-42010af0d7b6
secrets:
- name: default-token-uudge
```
2.2.3）
```sh
$ vi sa.yaml
[editor session not shown]
[delete line with key "resourceVersion"]
[add lines with "imagePullSecret:"]
```
2.2.4）
```sh
$ cat sa.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  creationTimestamp: 2015-08-07T22:02:39Z
  name: default
  namespace: default
  selfLink: /api/v1/namespaces/default/serviceaccounts/default
  uid: 052fb0f4-3d50-11e5-b066-42010af0d7b6
secrets:
- name: default-token-uudge
imagePullSecrets:
- name: myregistrykey
```
2.2.5）
```sh
$ kubectl replace serviceaccount default -f ./sa.yaml
serviceaccounts/default
```
这样，该空间下新Pod创建时将使用新的`imagePullSecret`。

