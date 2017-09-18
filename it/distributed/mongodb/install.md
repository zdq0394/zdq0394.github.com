# MongoDB安装
## Linux安装
### 下载安装包并解压
```sh
curl -O https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-3.4.9.tgz
tar -zxvf mongodb-linux-x86_64-3.4.9.tgz
mkdir -p mongodb
cp -R -n mongodb-linux-x86_64-3.4.9/ mongodb
export PATH=<mongodb-install-directory>/bin:$PATH
```

### 运行
首先创建数据库文件：

```
mkdir -p /data/db
```
/data/db是默认的数据库文件，所以可以直接启动mongd命令：

```
mongod
```

如果数据库文件不是默认文件，可以使用命令行参数**--dbpath**指定：

```
mongod --dbpath <path to data directory>
```

可以后台运行：

```
mongod --fork --logpath=/tmp/mongod.out
```