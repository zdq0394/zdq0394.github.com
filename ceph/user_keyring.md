# User and Keyring
## User
### 查看user
查看cluster中所有的users：
* ceph auth list
查看某个user
* ceph auth get TYPE.ID
* ceph auth export TYPE.ID

对于以上命令，可以增加`-o <file_name>`，从而保存结果为keyring文件。

### 创建user
* ceph auth add
* ceph auth get-or-create
* ceph auth get-or-create-key

### 为user添加权限
* ceph auth caps <USERTYPE.USERID> <daemon> 'allow [r|w|x|*|...] [pool=<pool_name>]
* ceph auth caps client.john mon 'allow r' osd 'allow rw pool=liverpool'
* ceph auth caps client.paul mon 'allow rw' osd 'allow rwx pool=liverpool'
* ceph auth caps client.brian-manager mon 'allow *' osd 'allow *'
* ceph auth caps client.ringo mon ' ' osd ' '

### 删除user
* ceph auth del {TYPE}.{ID}

### 显示
ceph auth print-key <TYPE>.<ID>

## keyering管理
* /etc/ceph/$cluster.$name.keyring
* /etc/ceph/$cluster.keyring
* /etc/ceph/keyring
* /etc/ceph/keyring.bin