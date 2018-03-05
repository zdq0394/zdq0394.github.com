# Ceph集群部署
## 基本环境配置
### 1.1 环境准备

3台主机，信息如下：

| hostname | IP           | 配置                        |
| -------- | ------------ | ------------------------- |
| ceph0    | 172.20.0.196 | 4核，4GB内存，ubuntu 14.04 LTS |
| ceph1    | 172.20.0.197 | 4核，4GB内存，ubuntu 14.04 LTS |
| ceph2    | 172.20.0.198 | 4核，4GB内存，ubuntu 14.04 LTS |

每台主机挂载一块200G的硬盘，开一个主分区，设备信息如下：

```
# lsblk
NAME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
vda    253:0    0    20G  0 disk 
├─vda1 253:1    0     2M  0 part 
├─vda2 253:2    0   476M  0 part /boot
└─vda3 253:3    0  19.5G  0 part /
vdb    253:16   0   200G  0 disk 
└─vdb1 253:17   0 186.3G  0 part
```

### 1.2 设置免密登录

​	选定一个节点作为主控节点（这里选的ceph0主机），建立从主控节点到其他节点的免密登录。

**1 生成秘钥：ssh-keygen**

```
root@ceph0:~# ssh-keygen
```

**2 拷贝密钥：ssh-copy-id your_dst_node**

```
root@ceph0:~# ssh-copy-id root@172.20.0.197
root@ceph0:~# ssh-copy-id root@172.20.0.198
```

**3 修改使hostname和ip对应**

在 `/etc/hosts` 里追加以下信息

```
172.20.0.196    ceph0
172.20.0.197    ceph1
172.20.0.198    ceph2
```

### 1.3 防火墙及安全设置（所有节点）

**1 防火墙相关**

​	Ceph Monitors 之间默认使用 6789 端口通信， OSD 之间默认用 6800:7300 这个范围内的端口通信。

```
root@ceph0:~# sudo firewall-cmd --zone=public --add-port=6789/tcp --permanent
sudo: firewall-cmd: command not found
```

**2 selinux相关**
​	设置selinux，如果报命令不存在，可以忽略这一步。

```
root@ceph0:~# sudo setenforce 0
sudo: setenforce: command not found
```

​	如果命令存在，执行如下操作

```
sudo setenforce 0
```

​	如果希望永久生效，则修改 /etc/selinux/config

```
This file controls the state of SELinux on the system.
SELINUX= can take one of these three values:
	enforcing - SELinux security policy is enforced.
	permissive - SELinux prints warnings instead of enforcing.
    disabled - No SELinux policy is loaded.
SELINUX=disabled
SELINUXTYPE= can take one of these two values:
    targeted - Targeted processes are protected,
    minimum - Modification of targeted policy. Only selected 
processes are protected.
    mls - Multi Level Security protection.
SELINUXTYPE=targeted
```

### 1.4 安装ntp服务（所有节点）

​	主要是用于ceph-mon之间的时间同步。在所有 Ceph 节点上安装 NTP 服务（特别是 Ceph Monitor 节点），以免因时钟漂移导致故障。确保在各 Ceph 节点上启动了 NTP 服务，并且要使用同一个 NTP 服务器。

```
sudo apt-get install ntp
```

### Ceph相关配置和安装

### 1.5 添加ceph用户（所有节点）

1、在各 Ceph 节点创建新用户

```
root@ceph0:~# sudo useradd -d /home/ceph -m ceph
```

2、确保各 Ceph 节点上新创建的用户都有 sudo 权限

```
root@ceph0:~# echo "ceph ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/ceph
ceph ALL = (root) NOPASSWD:ALL
root@ceph0:~# sudo chmod 0440 /etc/sudoers.d/ceph 
```

### 1.6 添加ceph安装源（所有节点）

**注**：建议直接写国内源，安装会比较快，填写初始源的话速度比较慢超过300秒后安装不成功。

国内源

```
wget -q -O- 'http://mirrors.163.com/ceph/keys/release.asc' > test.asc | sudo apt-key add -
echo deb http://mirrors.163.com/ceph/debian-jewel/ $(lsb_release -sc) main | sudo tee /etc/apt/sources.list.d/ceph.list
```

初始源

```
wget -q -O- 'https://download.ceph.com/keys/release.asc' 
echo deb https://download.ceph.com/debian-jewel/ $(lsb_release -sc) main | sudo tee /etc/apt/sources.list.d/ceph.list
```

### 1.7 安装ceph-deploy部署工具(仅主控节点)

更新仓库，并安装 ceph-deploy：

```
sudo apt-get update
sudo apt-get install ceph-deploy
```

### 1.8 ceph安装

**1 创建部署目录**

```
mkdir my-cluster && cd my-cluster/
```

**2 配置新节点**

```
root@ceph0:~/my-cluster# ceph-deploy new ceph0 ceph1 ceph2
root@ceph0:~/my-cluster# ls
ceph.conf  ceph-deploy-ceph.log  ceph.mon.keyring  release.asc
```

**3 安装**

```
root@ceph0:~/my-cluster# ceph-deploy install ceph0 ceph1 ceph2
……
……
[ceph2][INFO  ] Running command: ceph --version
[ceph2][DEBUG ] ceph version 10.2.5 (ecc23778eb545d8dd55e2e4735b53cc93f92e65b)
```

都出现如上输出表示成功安装完成。

### 1.9 配置并启动ceph-mon

```
ceph-deploy mon create-initial
```

至此，ceph集群的安装工作完毕。

​	运行 ceph -s可以看到当前集群的状态，3个mon，暂时没添加osd，有1个pool，pool的pg数目是64个。

```
root@ceph0:~/my-cluster# ceph -s
    cluster 4d7e1b04-2a4c-45aa-b6fe-a98241db0c2f
     health HEALTH_ERR
            no osds
     monmap e1: 3 mons at {ceph0=172.20.0.196:6789/0,ceph1=172.20.0.197:6789/0,ceph2=172.20.0.198:6789/0}
            election epoch 4, quorum 0,1,2 ceph0,ceph1,ceph2
     osdmap e1: 0 osds: 0 up, 0 in
            flags sortbitwise
      pgmap v2: 64 pgs, 1 pools, 0 bytes data, 0 objects
            0 kB used, 0 kB / 0 kB avail
                  64 creating
```