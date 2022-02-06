# 创建本地yum源
## 创建本地源
### 下载rpm包到本地目录
以本地目录`/opt/yum-offline`存储rpm包
mkdir -p /opt/yum-offline
yum groupinstall -y "Development Libraries" --downloadonly --downloaddir=/opt/yum-offline
yum groupinstall -y "Development Tools" --downloadonly --downloaddir=/opt/yum-offline
yum groupinstall -y "System Tools" --downloadonly --downloaddir=/opt/yum-offline
yum install -y gcc cpp gcc-c++ --downloadonly --downloaddir=/opt/yum-offline

### 创建yum源
yum install -y createrepo
createrepo /opt/yum-offline

### 备份yum repo
mkdir -p /etc/yum.repos.d/bak
mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/bak

### 创建repo文件，引用本地yum源
vi /etc/yum.repos.d/offline.repo

```text
[offline]
name=offline
baseurl=file:///opt/yum-offline/
gpgcheck=0
enabled=1
```
此时 /etc/yum.repos.d/ 目录下只有自定义的 offline.repo 仓库文件

### 修改yum.conf
修改yum的gpg检查选项，把其中的gpgcheck设置为0.

### 清空yum缓存
yum clean all
yum makecache

## 添加rpm包
### 将rpm包添加到/opt/yum-offline
### update repo
createrepo -update /opt/yum-offline
