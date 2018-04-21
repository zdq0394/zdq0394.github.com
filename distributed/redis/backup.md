# Redis数据备份与恢复
Redis SAVE命令用于创建当前数据库的备份。
## 实例
```
redis 127.0.0.1:6379> SAVE 
OK
```
该命令将在redis安装目录中创建dump.rdb文件。
## 恢复数据
如果需要恢复数据，只需将备份文件 (dump.rdb) 移动到redis安装目录并启动服务即可。

获取redis目录可以使用CONFIG命令，如下所示：
```
redis 127.0.0.1:6379> CONFIG GET dir
1) "dir"
2) "/usr/local/redis/bin"
```
## Bgsave
创建redis备份文件也可以使用命令BGSAVE，该命令在后台执行。
```
127.0.0.1:6379> BGSAVE
Background saving started
```
