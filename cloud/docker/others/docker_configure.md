# Docker 配置文件
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

## Centos