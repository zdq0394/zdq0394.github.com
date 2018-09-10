# Centos7.3安装部署最新版Zabbix
## 系统环境
```sh
cat /etc/redhat-release 
CentOS Linux release 7.3.1611 (Core) 
```
关闭防火墙及selinux
```sh
systemctl stop firewalld.service
systemctl disable firewalld.service
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
grep SELINUX=disabled /etc/selinux/config
setenforce 0
```

## 数据库安装及配置
安装mariadb
```sh
yum install mariadb-server mariadb -y
```
mariadb数据库的相关命令是：
```sh
systemctl start mariadb  #启动MariaDB
systemctl stop mariadb  #停止MariaDB
systemctl restart mariadb  #重启MariaDB
systemctl enable mariadb  #设置开机启动
```
## Zabbix安装及配置
Zabbix安装
```sh
rpm -ivh http://repo.zabbix.com/zabbix/3.4/rhel/7/x86_64/zabbix-release-3.4-1.el7.centos.noarch.rpm
yum install zabbix-server-mysql zabbix-web-mysql -y
```
创建数据库
```sh
create database zabbix character set utf8 collate utf8_bin;
grant all privileges on zabbix.* to zabbix@localhost identified by 'zabbix';
```
导入数据
```sh
zcat /usr/share/doc/zabbix-server-mysql-3.4.9/create.sql.gz | mysql -uzabbix -pzabbix zabbix
```
配置数据库用户及密码
```sh
grep -n '^'[a-Z] /etc/zabbix/zabbix_server.conf
38:LogFile=/var/log/zabbix/zabbix_server.log
49:LogFileSize=0
72:PidFile=/var/run/zabbix/zabbix_server.pid
99:DBName=zabbix
115:DBUser=zabbix
123:DBPassword=zabbix
314:SNMPTrapperFile=/var/log/snmptrap/snmptrap.log
432:Timeout=4
474:AlertScriptsPath=/usr/lib/zabbix/alertscripts
484:ExternalScripts=/usr/lib/zabbix/externalscripts
520:LogSlowQueries=3000
```

启动zabbix server并设置开机启动
```sh
systemctl enable zabbix-server
systemctl start zabbix-server
```
编辑Zabbix前端PHP配置,更改时区
```sh
vim /etc/httpd/conf.d/zabbix.conf
php_value date.timezone Asia/Shanghai
```
SELinux配置
```sh
setsebool -P httpd_can_connect_zabbix on
setsebool -P httpd_can_network_connect_db on
```
启动httpd并设置开机启动
```
systemctl start httpd
systemctl enable httpd
```
## 安装Zabbix Web
浏览器访问，并进行安装，一路next即可。
http://172.16.8.254/zabbix/

## zabbxi-agent安装及配置
安装zabbxi-agent
```sh
yum install zabbix-agent -y
```
配置zabbxi-agent
```sh
grep -n '^'[a-Z] /etc/zabbix/zabbix_agentd.conf 
13:PidFile=/var/run/zabbix/zabbix_agentd.pid
32:LogFile=/var/log/zabbix/zabbix_agentd.log
43:LogFileSize=0
97:Server=172.16.8.254
138:ServerActive=172.16.8.254
149:Hostname=Zabbix server
267:Include=/etc/zabbix/zabbix_agentd.d/*.conf
```
启动zabbxi-agent并设置开机启动
```sh
systemctl enable zabbix-agent.service
systemctl restart zabbix-agent.service
```

## 安装zabbix_sender
zabbix获取数据有超时时间，如果一些数据需要执行比较长的时间才能获取的话，那么zabbix会出现异常，考虑到这种情况，zabbix增加了**Trapper**功能，客户端自己提交数据给zabbix，这个通道便是trapper。

使用trapper的步骤如下：
1. 在zabbix中配置trapper监控项
2. 传递数据到zabbix中
```sh
rpm -ivh http://mirrors.aliyun.com/zabbix/zabbix/3.0/rhel/7/x86_64/zabbix-sender-3.0.5-1.el7.x86_64.rpm
```

## 参考
https://blog.csdn.net/xiegh2014/article/details/77571965