# Redis性能测试
Redis性能测试是通过同时执行多个命令实现的。
## 语法
redis-benchmark [option] [option value]
## 参数
* -h	指定服务器主机名	127.0.0.1
* -p	指定服务器端口	6379
* -s	指定服务器 socket	
* -c	指定并发连接数	50
* -n	指定请求数	10000
* -d	以字节的形式指定 SET/GET 值的数据大小	2
* -k	1=keep alive 0=reconnect	1
* -r	SET/GET/INCR 使用随机 key, SADD 使用随机值	
* -P	通过管道传输 <numreq> 请求	1
* -q	强制退出 redis。仅显示 query/sec 值	
* --csv	以 CSV 格式输出	
* -l	生成循环，永久执行测试	
* -t	仅运行以逗号分隔的测试命令列表。	
* -I	Idle 模式。仅打开 N 个 idle 连接并等待。