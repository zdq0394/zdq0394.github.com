# MongoDB备份与恢复
## MongoDB数据备份
在Mongodb中使用**mongodump**命令来备份MongoDB数据。该命令可以导出所有数据到指定目录中。

```
mongodump -h dbhost -d dbname -o dbdirectory
```
* -h：MongDB所在服务器地址，例如：127.0.0.1，当然也可以指定端口号：127.0.0.1:27017
* -d：需要备份的数据库实例，例如：test
* -o：备份的数据存放位置，**该目录需要提前建立**，在备份完成后，系统自动在dump目录下建立一个test目录，这个目录里面存放该数据库实例的备份数据。

其它参数：

* mongodump --host HOST_NAME --port PORT_NUMBER：该命令将备份所有MongoDB数据
* mongodump --dbpath DB_PATH --out BACKUP_DIRECTORY：mongodump --dbpath /data/db/ --out /data/backup/
* mongodump --collection COLLECTION --db DB_NAME：该命令将备份指定数据库的集合

## MongoDB数据恢复
Mongodb使用**mongorestore**命令来恢复备份的数据。

```
mongorestore -h <hostname><:port> -d dbname <path>
```

* --host <:port>, -h <:port>：MongoDB所在服务器地址，默认为： localhost:27017
* --db, -d：需要恢复的数据库实例，例如：test，当然这个名称也可以和备份时候的不一样，比如test2
* --drop：恢复的时候，先删除当前数据，然后恢复备份的数据。就是说，恢复后，备份后添加修改的数据都会被删除。
* <path>：mongorestore最后的一个参数，设置备份数据所在位置
* --dir：指定备份的目录

**不能同时指定<path>和--dir选项。**