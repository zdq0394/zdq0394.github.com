# Configure Service Accounts for Pods
**Service Account**为**Pod中运行的进程**提供身份信息（identity）。

* 当你（human user）通过**kubectl**命令访问Kubernetes集群时，你会被API Server认证为一个特殊的**User Account**：通常是`admin`。
* Pods中容器的进程也可以和API Server交互，进程也被认证为一个特殊的**Service Account**：通常是`default`。

## Use the Default Service Account to access the API Server
当你创建一个Pod时，如果没有指定service account，Pod会自动被分配一个当前namesapce的`default` service account。所谓当前namespace，就是Pod所属的namespace。通过命令`kubectl get pods/podName -o yaml`，可以发现，spec.serviceAccount和spec.serviceAccountName都被指定为`default`。
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

Pod内的进程可以使用自动挂载的service account credentials。
每个Pod都包含一个目录`/var/run/secrets/kubernetes.io/serviceaccount`，目录下包含三个文件：token，ca.crt和namespace。

## Use Multiple Service Accounts
每个namespace都有一个默认的service account resource：`default`，可以如下列出当前namespace下的service accounts resource：

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

当创建Pod时，可以通过`spec.serviceAccountName`来指定Pod要使用的service account。指定的service account必须已经存在。
