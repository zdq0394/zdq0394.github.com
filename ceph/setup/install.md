# Centos 7.3安装ceph集群
## 准备系统
1. 操作系统Centos 7.3，3台节点如下：
* 172.20.5.206  keceph1
* 172.20.5.207  keceph2
* 172.20.5.208  keceph3
2. 配置各个节点的hosts
keceph1:
```
172.20.5.206   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
172.20.5.206 keceph1
172.20.5.207 keceph2
172.20.5.208 keceph3
```
3. 关闭防火墙
```sh
systemctl  stop firewalld
systemctl  disable firewalld
```
4. 关闭selinux
```sh
setenforce 0
```
5. 以keceph1作为部署节点，设置对另外2个节点的免密钥访问权限。

## 安装CEPH部署工具源
1. 在各节点上安装启用ceph软件仓库，启用可选软件库
```sh
 yum install yum-utils -y 

 yum-config-manager --add-repo https://dl.fedoraproject.org/pub/epel/7/x86_64/ && yum install --nogpgcheck -y epel-release && rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7 && rm -fr /etc/yum.repos.d/dl.fedoraproject.org*

 yum install yum-plugin-priorities -y

```
2. 在各节点上安装安装ntp
```sh
yum install ntp ntpdate ntp-doc -y

```

## 设置yum源并安装ceph-deploy
1. 在各个节点的/etc/yum.repos.d/目录下创建ceph.repo然后写入以下内容
vim /etc/yum.repos.d/ceph.repo
```sh
[Ceph]
name=Ceph packages for $basearch
baseurl=http://mirrors.163.com/ceph/rpm-jewel/el7/$basearch
enabled=1
gpgcheck=0
type=rpm-md
gpgkey=https://mirrors.163.com/ceph/keys/release.asc
priority=1

[Ceph-noarch]
name=Ceph noarch packages
baseurl=http://mirrors.163.com/ceph/rpm-jewel/el7/noarch
enabled=1
gpgcheck=0
type=rpm-md
gpgkey=https://mirrors.163.com/ceph/keys/release.asc
priority=1

[ceph-source]
name=Ceph source packages
baseurl=http://mirrors.163.com/ceph/rpm-jewel/el7/SRPMS
enabled=1
gpgcheck=0
type=rpm-md
gpgkey=https://mirrors.163.com/ceph/keys/release.asc
priority=1
```

2. 在部署节点上进行安装准备
在当前用户root目录下：
```sh
mkdir ceph-cluster
cd ceph-cluster
yum install ceph-deploy -y
```
## 安装ceph创建集群
1. 在部署节点上修改~/.ssh/config文件(若没有则创建)增加一下内容
```
Host    keceph1
Hostname  172.20.5.206
User    root

Host    keceph2
Hostname  172.20.5.207
User    root

Host    keceph3
Hostname  172.20.5.208
User    root
```
2. 进入到创建的ceph-cluster文件夹下，执行命令
```sh
ceph-deploy new keceph1 keceph2 keceph3
```
另外，如果在任何时候遇到问题并想重新开始，请执行以下操作清除Ceph软件包，并清除所有数据和配置：
```sh
ceph-deploy purge keceph1 keceph2 keceph3
ceph-deploy purgedata keceph1 keceph2 keceph3
ceph-deploy forgetkeys && rm -fr ceph.*
```

3. 安装集群
在生成的ceph.conf中加入（写入[global] 段下）
```
vi ceph.conf
加入下面一行
osd pool default size = 3

如果是ext4文件系统，需要加入下面2行：
osd max object name len = 256
osd max object namespace len = 64
```

5. 如果你有多个网卡，可以把 public network 写入 Ceph 配置文件的 [global] 段下
```
#public network = {ip-address}/{netmask}
```

6. 部署ceph
```
ceph-deploy install keceph1 keceph2 keceph3
```

7. 配置初始 monitor(s)、并收集所有密钥
```sh
ceph-deploy mon create-initial
```

8. 新建osd
添加三个 OSD ，登录到Ceph节点、并给OSD守护进程创建一个目录。
``` sh
#ssh keceph1
#mkdir /var/local/osd0
#chown -R ceph:ceph /var/local/osd0/

#ssh keceph2
#mkdir /var/local/osd1
#chown -R ceph:ceph /var/local/osd1/

#ssh keceph3
#mkdir /var/local/osd2
#chown -R ceph:ceph /var/local/osd1/
```
9. 从部署节点执行ceph-deploy来准备OSD
```sh
ceph-deploy osd prepare keceph1:/var/local/osd0 keceph2:/var/local/osd1 keceph3:/var/local/osd2
```
10. 激活OSD
```sh
ceph-deploy osd activate keceph1:/var/local/osd0 keceph2:/var/local/osd1 keceph3:/var/local/osd2
```
11. 确保你对ceph.client.admin.keyring有正确的操作权限
```sh
chmod +r /etc/ceph/ceph.client.admin.keyring
```





