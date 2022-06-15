# 二进制安装docker及docker-buildx
## 安装docker
1. 下载二进制安装包：`https://download.docker.com/linux/static/stable/x86_64/docker-20.10.9.tgz`
2. 解压压缩文件：`tar zxf docker-20.10.9.tgz`
3. 拷贝二进制文件到`/usr/bin`
```sh
cp docker/* /usr/bin/
```
4. 创建containerd的service文件
```sh
cat >/etc/systemd/system/containerd.service <<EOF
[Unit]
Description=containerd container runtime
Documentation=https://containerd.io
After=network.target local-fs.target

[Service]
ExecStartPre=-/sbin/modprobe overlay
ExecStart=/usr/bin/containerd
Type=notify
Delegate=yes
KillMode=process
Restart=always
RestartSec=5
LimitNPROC=infinity
LimitCORE=infinity
LimitNOFILE=1048576
TasksMax=infinity
OOMScoreAdjust=-999

[Install]
WantedBy=multi-user.target
EOF
```
5. 启动containerd
```sh
systemctl enable --now containerd.service
```

6. 准备docker的service文件
```sh
cat > /etc/systemd/system/docker.service <<EOF
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network-online.target firewalld.service containerd.service
Wants=network-online.target
Requires=docker.socket containerd.service

[Service]
Type=notify
ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
ExecReload=/bin/kill -s HUP $MAINPID
TimeoutSec=0
RestartSec=2
Restart=always
StartLimitBurst=3
StartLimitInterval=60s
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
TasksMax=infinity
Delegate=yes
KillMode=process
OOMScoreAdjust=-500

[Install]
WantedBy=multi-user.target
EOF
```

7. 准备docker的socket文件
```sh
cat > /etc/systemd/system/docker.socket <<EOF
[Unit]
Description=Docker Socket for the API

[Socket]
ListenStream=/var/run/docker.sock
SocketMode=0660
SocketUser=root
SocketGroup=docker

[Install]
WantedBy=sockets.target
EOF
```

8. 创建docker组: `groupadd docker`

9. 启动docker
```sh
systemctl enable --now docker.socket  && systemctl enable --now docker.service
```

10. 验证 `docker info`

11. 配置`/etc/docker/daemon.json`，开启experimental特性
```sh
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "experimental": true
}
EOF

重启docker
systemctl restart docker
```

## 安装docker-buildx
1. 下载并安装命令
``` sh
mkdir -pv ~/.docker/cli-plugins/
wget -O ~/.docker/cli-plugins/docker-buildx https://github.com/docker/buildx/releases/download/v0.8.2/buildx-v0.8.2.linux-amd64
chmod a+x ~/.docker/cli-plugins/docker-buildx 
```
2. 设置experimental参数
```sh
vim ~/.docker/config.json
{
    ...
    "experimental": "enabled",
    ...
}
```

3. 验证: `docker buildx version`
