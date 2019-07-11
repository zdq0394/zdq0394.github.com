# pidstat命令详解
## pidstat概述
'pidstat'是'sysstat'工具的一个命令，用于监控全部或指定进程的cpu、内存、线程、设备IO等系统资源的占用情况。
'pidstat'首次运行时显示自系统启动开始的各项统计信息，之后运行pidstat将显示自上次运行该命令以后的统计信息。
用户可以通过指定统计的次数和时间来获得所需的统计信息。
## pidstat参数
常用的参数：
* -u：默认的参数，显示各个进程的cpu使用统计
* -r：显示各个进程的内存使用统计
* -d：显示各个进程的IO使用情况
* -p：指定进程号
* -w：显示每个进程的上下文切换情况
* -t：显示选择任务的线程的统计信息外的额外信息
* -T { TASK | CHILD | ALL }
    * TASK表示报告独立的task。
    * CHILD关键字表示报告进程下所有线程统计信息。
    * ALL表示报告独立的task和task下面的所有线程。
* -V：版本号
* -h：在一行上显示了所有活动，这样其他程序可以容易解析。
* -I：在SMP环境，表示任务的CPU使用率/内核数量
* -l：显示命令名和所有参数
## 示例
### 查看所有进程的CPU使用情况
* **pidstat**
* **pidstat -u -p ALL**
```sh
[root@SCSP01815 ~]# pidstat -u -p ALL
Linux 4.17.4-1.el7.elrepo.x86_64 (SCSP01815) 	08/01/2018 	_x86_64_	(32 CPU)

10:10:18 AM   UID       PID    %usr %system  %guest    %CPU   CPU  Command
10:10:18 AM     0         1    0.00    0.00    0.00    0.00     4  systemd
10:10:18 AM     0         2    0.00    0.00    0.00    0.00     0  kthreadd
10:10:18 AM     0         3    0.00    0.00    0.00    0.00     0  rcu_gp
10:10:18 AM     0         5    0.00    0.00    0.00    0.00     0  kworker/0:0H
10:10:18 AM     0         8    0.00    0.00    0.00    0.00    10  mm_percpu_wq
10:10:18 AM     0         9    0.00    0.01    0.00    0.01     0  ksoftirqd/0
10:10:18 AM     0        10    0.00    0.30    0.00    0.30     9  rcu_sched
10:10:18 AM     0        11    0.00    0.00    0.00    0.00     0  rcu_bh
10:10:18 AM     0        12    0.00    0.00    0.00    0.00     0  migration/0
```
详细说明：
* PID：进程ID
* %usr：进程在用户空间占用cpu的百分比
* %system：进程在内核空间占用cpu的百分比
* %guest：进程在虚拟机占用cpu的百分比
* %CPU：进程占用cpu的百分比
* CPU：处理进程的cpu编号
* Command：当前进程对应的命令

### cpu使用情况统计(-u)
```
[root@SCSP01815 ~]# pidstat -u -p 29540
Linux 4.17.4-1.el7.elrepo.x86_64 (SCSP01815) 	08/01/2018 	_x86_64_	(32 CPU)

10:15:47 AM   UID       PID    %usr %system  %guest    %CPU   CPU  Command
10:15:47 AM     0     29540  100.00   20.27    0.00  100.00     4  prometheus
```
### 内存使用情况统计(-r)
```
[root@SCSP01815 ~]# pidstat -r -p 29540
Linux 4.17.4-1.el7.elrepo.x86_64 (SCSP01815) 	08/01/2018 	_x86_64_	(32 CPU)

10:16:08 AM   UID       PID  minflt/s  majflt/s     VSZ    RSS   %MEM  Command
10:16:08 AM     0     29540   4200.02      0.00 76160696 66588584  50.48  prometheus
```
详细说明：
* PID：进程标识符
* Minflt/s:任务每秒发生的次要错误，不需要从磁盘中加载页
* Majflt/s:任务每秒发生的主要错误，需要从磁盘中加载页
* VSZ：虚拟地址大小，虚拟内存的使用KB
* RSS：常驻集合大小，非交换区五里内存使用KB
* Command：task命令名

### 进程的IO使用情况(-d)
```sh
[root@SCSP01815 ~]# pidstat -d -p 29540
Linux 4.17.4-1.el7.elrepo.x86_64 (SCSP01815) 	08/01/2018 	_x86_64_	(32 CPU)

10:18:10 AM   UID       PID   kB_rd/s   kB_wr/s kB_ccwr/s  Command
10:18:10 AM     0     29540    373.49  42563.69      9.73  prometheus
```
报告IO统计显示以下信息：
* PID：进程id
* kB_rd/s：每秒从磁盘读取的KB
* kB_wr/s：每秒写入磁盘KB
* kB_ccwr/s：任务取消的写入磁盘的KB。当任务截断脏的pagecache的时候会发生。
* COMMAND:task的命令名

### 进程的上下文切换情况（-w）
```sh
[root@SCSP01815 ~]# pidstat -w -p 29540
Linux 4.17.4-1.el7.elrepo.x86_64 (SCSP01815) 	08/01/2018 	_x86_64_	(32 CPU)

10:21:55 AM   UID       PID   cswch/s nvcswch/s  Command
10:21:55 AM     0     29540    192.72      6.05  prometheus
```
输出详细说明
* PID:进程id
* Cswch/s:每秒主动任务上下文切换数量
* Nvcswch/s:每秒被动任务上下文切换数量
* Command:命令名

### 显示选择任务的线程的统计信息外的额外信息 (-t)
```sh
[root@SCSP01815 ~]# pidstat -t -p 29540
Linux 4.17.4-1.el7.elrepo.x86_64 (SCSP01815) 	08/01/2018 	_x86_64_	(32 CPU)

10:23:02 AM   UID      TGID       TID    %usr %system  %guest    %CPU   CPU  Command
10:23:02 AM     0     29540         -  100.00   20.27    0.00  100.00     4  prometheus
10:23:02 AM     0         -     29540    9.90    0.48    0.00   10.38     4  |__prometheus
10:23:02 AM     0         -     29561    0.18    0.45    0.00    0.63    11  |__prometheus
10:23:02 AM     0         -     29562    9.47    0.46    0.00    9.93    11  |__prometheus
10:23:02 AM     0         -     29563    0.00    0.00    0.00    0.00    22  |__prometheus
10:23:02 AM     0         -     29564    0.00    0.00    0.00    0.00     8  |__prometheus
10:23:02 AM     0         -     29566   10.23    0.49    0.00   10.72    12  |__prometheus
10:23:02 AM     0         -     29567   10.08    0.49    0.00   10.56    26  |__prometheus
10:23:02 AM     0         -     29568    9.72    0.48    0.00   10.19    30  |__prometheus
10:23:02 AM     0         -     29569    7.52    0.33    0.00    7.86    14  |__prometheus
```
详细说明
* TGID:主线程的表示
* TID:线程id
* %usr：进程在用户空间占用cpu的百分比
* %system：进程在内核空间占用cpu的百分比
* %guest：进程在虚拟机占用cpu的百分比
* %CPU：进程占用cpu的百分比
* CPU：处理进程的cpu编号
* Command：当前进程对应的命令

### pidstat -T
```sh
pidstat -T TASK
pidstat -T CHILD
pidstat -T ALL
```
```sh
[root@SCSP01815 ~]# pidstat -T TASK -p 29540
Linux 4.17.4-1.el7.elrepo.x86_64 (SCSP01815) 	08/01/2018 	_x86_64_	(32 CPU)

10:25:04 AM   UID       PID    %usr %system  %guest    %CPU   CPU  Command
10:25:04 AM     0     29540  100.00   20.27    0.00  100.00     4  prometheus
```
```sh
[root@SCSP01815 ~]# pidstat -T CHILD -p 29540
Linux 4.17.4-1.el7.elrepo.x86_64 (SCSP01815) 	08/01/2018 	_x86_64_	(32 CPU)

10:25:32 AM   UID       PID    usr-ms system-ms  guest-ms  Command
10:25:32 AM     0     29540 6926803870 341385170         0  prometheus
```
```sh
[root@SCSP01815 ~]# pidstat -T ALL -p 29540
Linux 4.17.4-1.el7.elrepo.x86_64 (SCSP01815) 	08/01/2018 	_x86_64_	(32 CPU)

10:25:50 AM   UID       PID    %usr %system  %guest    %CPU   CPU  Command
10:25:50 AM     0     29540  100.00   20.27    0.00  100.00     4  prometheus

10:25:50 AM   UID       PID    usr-ms system-ms  guest-ms  Command
10:25:50 AM     0     29540 6926860200 341388600         0  prometheus
```
详细说明:
* PID:进程id
* Usr-ms:任务和子线程在用户级别使用的毫秒数。
* System-ms:任务和子线程在系统级别使用的毫秒数。
* Guest-ms:任务和子线程在虚拟机(running a virtual processor)使用的毫秒数。
* Command:命令名

