# yum repo相关问题
1. openeuler相关yum源
https://repo.openeuler.org/

2. 创建源
```sh
yum -y install createrepo yum-utils
createrepo -pdo /yum/yum-custom/ /yum/yum-custom/
```

3. 同步源
```sh
reposync -r base -p /mirrors/Packege -d
或者
dnf --repo base reposync -p /mirrors/Packege
```

4. 自动更新源
```sh
vim /cron/repository.sh 
reposync -r base -p /mirrors/Packege -d
reposync -r base -p /mirrors/Packege

crontab -e
添加：
0 0 1 * * sh /yum/repository.sh
```
