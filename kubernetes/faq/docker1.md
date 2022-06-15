# docker常见问题1
1. 如何修改docker的cgroup driver?
修改/etc/docker/daemon.json
{
...
"exec-opts": ["native.cgroupdriver=systemd"]
}

