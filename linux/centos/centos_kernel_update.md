# Centos内核升级
## 配置代理
```sh
export http_proxy=<HTTP_PROXY>
export https_proxy=<HTTPS_PROXY>
```
## 升级内核

### 载入公钥
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
### 安装ELRepo
rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
### 载入elrepo-kernel元数据
yum --disablerepo=\* --enablerepo=elrepo-kernel repolist
### 查看可用的rpm包
yum --disablerepo=\* --enablerepo=elrepo-kernel list kernel*
### 安装最新版本的kernel
yum --disablerepo=\* --enablerepo=elrepo-kernel install -y kernel-ml.x86_64
## 设置默认启动
grub2-set-default 0

## 重启
```sh
reboot
```
查看新的版本
```sh
uname -r
4.17.2-1.el7.elrepo.x86_64
```
## 内核工具包一并升级

### 重启配置代理
```sh
export http_proxy=<HTTP_PROXY>
export https_proxy=<HTTPS_PROXY>
```
### 删除旧版本工具包
yum remove kernel-tools-libs.x86_64 kernel-tools.x86_64
### 安装新版本工具包
yum --disablerepo=\* --enablerepo=elrepo-kernel install -y kernel-ml-tools.x86_64


