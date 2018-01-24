# 为容器定义Command和arguments

## 创建Pod时定义Command和arguments
在Pod的配置文件中，通过添加command字段定义一个命令，通过添加args字段定义参数。

在Pod的配置文件中定义的command和args将覆盖container镜像中默认的entrypoint和cmd。覆盖规则[参见详情](../docker/kubernetes-cmd-args-inject-into-container.md)

	apiVersion: v1
	kind: Pod
	metadata:
	  name: command-demo
	  labels:
	    purpose: demonstrate-command
	spec:
	  containers:
	  - name: command-demo-container
	    image: debian
	    command: ["printenv"]
	    args: ["HOSTNAME", "KUBERNETES_PORT"]

## 使用environment variables定义arguments

	env:
	- name: MESSAGE
	  value: "hello world"
	command: ["/bin/echo"]
	args: ["$(MESSAGE)"]

## Run a command in a shell

	command: ["/bin/sh"]
	args: ["-c", "while true; do echo hello; sleep 10;done"]