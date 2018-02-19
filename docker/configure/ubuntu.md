# Docker Ubuntu 配置文件
## Ubuntu
配置文件：/etc/default/docker

启动文件：/lib/systemd/system/docker.service

要在启动文件中修改路径引用配置文件中的参数。

``` sh
[Unit]
Description=Docker Application Container Engine
Documentation=http://docs.docker.com
After=network.target docker.socket
Requires=docker.socket

[Service]
EnvironmentFile=-/etc/default/docker  #这里添加了 EnvironmentFile 参数
ExecStart=/usr/bin/docker -d $DOCKER_OPTS -H fd://  # 增加了 $DOCKER_OPTS
MountFlags=slave
LimitNOFILE=1048576
LimitNPROC=1048576
LimitCORE=infinity

[Install]
WantedBy=multi-user.target
```

## Ubuntu 16.04配置代理
1. 创建配置文件： /etc/systemd/system/docker.service.d/http-proxy.conf

2. 添加如下内容：
``` sh
Environment="HTTP_PROXY=http://xxxxxxxx:1080"
```
3. 刷新配置： systemctl daemon-reload
4. 查看配置： systemctl show --property=Environment docker
5. 重启： systemctl restart docker 

## docker build时使用代理
### --build-arg方式
docker build --build-arg http_proxy=http://219.135.102.36:8998 ...
### --network host
宿主机配置http_proxy，构建时创建的临时容器使用宿主机网络。
