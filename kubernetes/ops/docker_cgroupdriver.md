# Docker配置: cgroup driver
Docker配置文件/etc/docker/daemon.json

{
    "exec-opts": ["native.cgroupdriver=systemd"]
}
