# Pod时区设置
kubernetes集群中，默认运行的容器采用的是UTC时间，需要改成CST时间(我们常用时区)。

修改方法是使用hostPath volume将宿主机时区设置挂在到容器中，如下面的例子中的**volumeMounts**和**volumes**，将他们添加到自己的设置中即可。

``` yaml

apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: tz-test
spec:
  replicas: 1
  template:
    metadata:
      labels:
        run: tz-test
    spec:
      containers:
      - name: tz-test
        image: nginx
        imagePullPolicy: IfNotPresent
        volumeMounts:
        - name: tz-config
          mountPath: /etc/localtime
          readOnly: true
      volumes:
      - name: tz-config
        hostPath:
          path: /usr/share/zoneinfo/Asia/Shanghai

```