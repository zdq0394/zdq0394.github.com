# sar
## 介绍
`sar`，全称`System Activity Reporter`，是一个系统活动报告工具，既可以实时查看系统的当前活动，又可以配置保存和报告历史统计数据。
它是目前Linux最为全面的系统性能分析工具之一，可以从多方面对系统的活动进行报告：
* 文件的读写情况
* 系统调用的使用情况
* 磁盘IO
* CPU效率
* 进程活动
* IPC

`sar`命令由sysstat安装。

## 使用方法
sar [ options ]  [ interval [ count ] ]
### sar -u
统计CPU的使用情况
```sh
sar -u 1 2
Linux 3.10.0-327.el7.x86_64 (scsp00348) 	04/25/2019 	_x86_64_	(32 CPU)

10:02:47 AM     CPU     %user     %nice   %system   %iowait    %steal     %idle
10:02:48 AM     all      0.59      0.00      0.09      0.00      0.00     99.31
10:02:49 AM     all      1.10      0.00      0.16      0.00      0.00     98.75
Average:        all      0.85      0.00      0.13      0.00      0.00     99.03
```

### sar -P [CPUID]
统计某个CPU的使用情况：
* sar -P 0 1 2：统计0号cpu，间隔1秒，统计2次。
* sar -P 1 1 2：统计1号cpu，间隔1秒，统计2次。
* sar -P ALL 1 2：统计所有CPU，间隔1秒，统计2次。

### sar -q
统计平均负载情况:
* runq-sz：运行队列的长度（等待运行的进程数，每核的CP不能超过3个）
* plist-sz：进程列表中的进程（processes）和线程数（threads）的数量
* ldavg-1：最后1分钟的CPU平均负载，即将多核CPU过去一分钟的负载相加再除以核心数得出的平均值，5分钟和15分钟以此类推
* ldavg-5：最后5分钟的CPU平均负载
* ldavg-15：最后15分钟的CPU平均负载
* blocked：阻塞状态的进程数
```sh
sar -q 1 2
Linux 3.10.0-327.el7.x86_64 (scsp00348) 	04/25/2019 	_x86_64_	(32 CPU)

10:11:02 AM   runq-sz  plist-sz   ldavg-1   ldavg-5  ldavg-15   blocked
10:11:03 AM         0      1804      0.10      0.06      0.12         0
10:11:04 AM         0      1806      0.10      0.06      0.12         0
Average:            0      1805      0.10      0.06      0.12         0

```

### sar -r
统计内存使用情况：
* kbmemfree：空闲的物理内存大小
* kbmemused：使用中的物理内存大小
* %memused：物理内存使用率
* kbbuffers：内核中作为缓冲区使用的物理内存大小，kbbuffers和kbcached:这两个值就是free命令中的buffer和cache
* kbcached：缓存的大小
* kbcommit：保证当前系统正常运行所需要的最小内存，即为了确保内存不溢出而需要的最少内存（物理内存+swap分区）。
* %commit：这个值是kbcommit与内存总量（物理内存+swap分区）一个百分比值。
``` sh
sar -r 1 2
Linux 3.10.0-327.el7.x86_64 (scsp00348) 	04/25/2019 	_x86_64_	(32 CPU)

10:14:08 AM kbmemfree kbmemused  %memused kbbuffers  kbcached  kbcommit   %commit  kbactive   kbinact   kbdirty
10:14:09 AM    384644  32432084     98.83    191572  10711928  31235028     95.18  19785964   7049492       316
10:14:10 AM    384752  32431976     98.83    191572  10711928  31235028     95.18  19786052   7049492       316
Average:       384698  32432030     98.83    191572  10711928  31235028     95.18  19786008   7049492       316
```

### sar -S
统计swap分区的使用情况
### sar -W
统计swap分区的换入换出页面数量
### sar -b
统计IO和传递速率的情况：
* tps：磁盘每秒钟的IO总数，等于iostat中的tps
* rtps：每秒钟从磁盘读取的IO总数
* wtps：每秒钟从写入到磁盘的IO总数
* bread/s：每秒钟从磁盘读取的块总数
* bwrtn/s：每秒钟此写入到磁盘的块总数
```sh
sar -b 1 2
Linux 3.10.0-327.el7.x86_64 (scsp00348) 	04/25/2019 	_x86_64_	(32 CPU)

10:21:46 AM       tps      rtps      wtps   bread/s   bwrtn/s
10:21:47 AM      0.00      0.00      0.00      0.00      0.00
10:21:48 AM      0.00      0.00      0.00      0.00      0.00
Average:         0.00      0.00      0.00      0.00      0.00
```

### sar -d
磁盘使用详情统计:
* DEV: 磁盘设备的名称，如果不加-p，会显示dev253-0类似的设备名称，因此加上-p显示的名称更直接
* tps: 每秒I/O的传输总数
* rd_sec/s: 每秒读取的扇区的总数
* wr_sec/s: 每秒写入的扇区的 总数
* avgrq-sz: 平均每次次磁盘I/O操作的数据大小（扇区）
* avgqu-sz: 磁盘请求队列的平均长度
* await: 从请求磁盘操作到系统完成处理，每次请求的平均消耗时间，包括请求队列等待时间，单位是毫秒（1秒等于1000毫秒），等于寻道时间+队列时间+服务时间
* svctm: I/O的服务处理时间，即不包括请求队列中的时间
* %util: I/O请求占用的CPU百分比，值越高，说明I/O越慢
```sh
sar -d 1 2
Linux 3.10.0-327.el7.x86_64 (scsp00348) 	04/25/2019 	_x86_64_	(32 CPU)

10:24:03 AM       DEV       tps  rd_sec/s  wr_sec/s  avgrq-sz  avgqu-sz     await     svctm     %util
10:24:04 AM    dev8-0      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00
10:24:04 AM  dev253-0      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00
10:24:04 AM  dev253-1      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00

10:24:04 AM       DEV       tps  rd_sec/s  wr_sec/s  avgrq-sz  avgqu-sz     await     svctm     %util
10:24:05 AM    dev8-0      1.00      0.00      8.00      8.00      0.00      0.00      0.00      0.00
10:24:05 AM  dev253-0      1.00      0.00      8.00      8.00      0.00      0.00      0.00      0.00
10:24:05 AM  dev253-1      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00

Average:          DEV       tps  rd_sec/s  wr_sec/s  avgrq-sz  avgqu-sz     await     svctm     %util
Average:       dev8-0      0.50      0.00      4.00      8.00      0.00      0.00      0.00      0.00
Average:     dev253-0      0.50      0.00      4.00      8.00      0.00      0.00      0.00      0.00
Average:     dev253-1      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00
```

### sar -v
进程、inode、文件和锁表状态i情况统计:
* dentunusd 在缓冲目录条目中没有使用的条目数量
* file-nr 被系统使用的文件句柄数量
* inode-nr 已经使用的索引数量 
* pty-nr 使用的pty数量

### sar -n
统计网络信息。

### sar -n DEV
统计网络接口信息:
* IFACE 本地网卡接口的名称
* rxpck/s 每秒钟接受的数据包
* txpck/s 每秒钟发送的数据库
* rxKB/S 每秒钟接受的数据包大小，单位为KB
* txKB/S 每秒钟发送的数据包大小，单位为KB
* rxcmp/s 每秒钟接受的压缩数据包
* txcmp/s 每秒钟发送的压缩包
* rxmcst/s 每秒钟接收的多播数据包  
```sh
sar -n DEV 1 1
Linux 3.10.0-327.el7.x86_64 (scsp00348) 	04/25/2019 	_x86_64_	(32 CPU)

10:31:09 AM     IFACE   rxpck/s   txpck/s    rxkB/s    txkB/s   rxcmp/s   txcmp/s  rxmcst/s
10:31:10 AM      eno1      2.00      0.00      0.12      0.00      0.00      0.00      0.00
10:31:10 AM      eno2    513.00    387.00     89.35    125.91      0.00      0.00      0.00
10:31:10 AM      eno3      0.00      0.00      0.00      0.00      0.00      0.00      0.00
10:31:10 AM      eno4      0.00      0.00      0.00      0.00      0.00      0.00      0.00
10:31:10 AM     bond0    515.00    387.00     89.48    125.91      0.00      0.00      0.00
10:31:10 AM        lo      3.00      3.00      0.23      0.23      0.00      0.00      0.00
10:31:10 AM    ens2f0      0.00      0.00      0.00      0.00      0.00      0.00      0.00
10:31:10 AM    ens2f1      0.00      0.00      0.00      0.00      0.00      0.00      0.00
10:31:10 AM   docker0      0.00      0.00      0.00      0.00      0.00      0.00      0.00

Average:        IFACE   rxpck/s   txpck/s    rxkB/s    txkB/s   rxcmp/s   txcmp/s  rxmcst/s
Average:         eno1      2.00      0.00      0.12      0.00      0.00      0.00      0.00
Average:         eno2    513.00    387.00     89.35    125.91      0.00      0.00      0.00
Average:         eno3      0.00      0.00      0.00      0.00      0.00      0.00      0.00
Average:         eno4      0.00      0.00      0.00      0.00      0.00      0.00      0.00
Average:        bond0    515.00    387.00     89.48    125.91      0.00      0.00      0.00
Average:           lo      3.00      3.00      0.23      0.23      0.00      0.00      0.00
Average:       ens2f0      0.00      0.00      0.00      0.00      0.00      0.00      0.00
Average:       ens2f1      0.00      0.00      0.00      0.00      0.00      0.00      0.00
Average:      docker0      0.00      0.00      0.00      0.00      0.00      0.00      0.00

```
### sar -n EDEV
统计网络接口错误信息:
* IFACE 网卡名称
* rxerr/s 每秒钟接收到的损坏的数据包
* txerr/s 每秒钟发送的数据包错误数
* coll/s 当发送数据包时候，每秒钟发生的冲撞（collisions）数，这个是在半双工模式下才有
* rxdrop/s 当由于缓冲区满的时候，网卡设备接收端每秒钟丢掉的网络包的数目
* txdrop/s 当由于缓冲区满的时候，网络设备发送端每秒钟丢掉的网络包的数目
* txcarr/s  当发送数据包的时候，每秒钟载波错误发生的次数
* rxfram   在接收数据包的时候，每秒钟发生的帧对其错误的次数
* rxfifo    在接收数据包的时候，每秒钟缓冲区溢出的错误发生的次数
* txfifo    在发生数据包 的时候，每秒钟缓冲区溢出的错误发生的次数
```sh
sar -n EDEV 1 1
Linux 3.10.0-327.el7.x86_64 (scsp00348) 	04/25/2019 	_x86_64_	(32 CPU)

10:31:58 AM     IFACE   rxerr/s   txerr/s    coll/s  rxdrop/s  txdrop/s  txcarr/s  rxfram/s  rxfifo/s  txfifo/s
10:31:59 AM      eno1      0.00      0.00      0.00      2.00      0.00      0.00      0.00      0.00      0.00
10:31:59 AM      eno2      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00
10:31:59 AM      eno3      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00
10:31:59 AM      eno4      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00
10:31:59 AM     bond0      0.00      0.00      0.00      2.00      0.00      0.00      0.00      0.00      0.00
10:31:59 AM        lo      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00
10:31:59 AM    ens2f0      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00
10:31:59 AM    ens2f1      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00
10:31:59 AM   docker0      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00

Average:        IFACE   rxerr/s   txerr/s    coll/s  rxdrop/s  txdrop/s  txcarr/s  rxfram/s  rxfifo/s  txfifo/s
Average:         eno1      0.00      0.00      0.00      2.00      0.00      0.00      0.00      0.00      0.00
Average:         eno2      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00
Average:         eno3      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00
Average:         eno4      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00
Average:        bond0      0.00      0.00      0.00      2.00      0.00      0.00      0.00      0.00      0.00
Average:           lo      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00
Average:       ens2f0      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00
Average:       ens2f1      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00
Average:      docker0      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00      0.00
```
### sar -n SOCK
统计套接字使用信息:
* totsck 当前被使用的socket总数
* tcpsck 当前正在被使用的TCP的socket总数
* udpsck  当前正在被使用的UDP的socket总数
* rawsck 当前正在被使用于RAW的skcket总数
* if-frag  当前的IP分片的数目
* tcp-tw TCP套接字中处于TIME-WAIT状态的连接数量
```sh
sar -n SOCK 1 1
Linux 3.10.0-327.el7.x86_64 (scsp00348) 	04/25/2019 	_x86_64_	(32 CPU)

10:34:14 AM    totsck    tcpsck    udpsck    rawsck   ip-frag    tcp-tw
10:34:15 AM       944       122         4         0         0         2
Average:          944       122         4         0         0         2

```
### sar -n IP
统计IP数据包信息

### sar -n EIP
统计IP数据包错误信息

### sar -n TCP
统计TCP报文信息

### sar -n ETCP
统计TCP报文错误信息