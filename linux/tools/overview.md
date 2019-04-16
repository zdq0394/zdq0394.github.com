# Linux性能分析工具
## 压力模拟工具
stress是一个Linux系统压力测试工具。
也可以安装stress-ng进行更全面的测试。
```sh
stress --cpu 1 --timeout 600
stress -c 8 --timeout 600
stress-ng -i 1 --hdd 1 --timeout 600  #模拟磁盘IO
```
## CPU性能分析工具
### CPU性能指标
* CPU使用率
* CPU负载
* 上下文切换
* CPU缓存命中率
### 指标和工具
| 性能指标 | 工具 | 说明 |
| ------ | ------ | ------ |
| 平均负载 | uptime、top  | uptime最简单；top提供了更全的指标 |
| 系统整体CPU使用率 | top、mpstat、vmstat、sar、/proc/stat | top、vmstat和mpstat只可以动态查看，而sar还可以记录历史数；/proc/stat是其它性能工具的数据来源 |
| 进程CPU使用率 | top、pidstat、ps、htop、atop | top和ps可以按cpu使用率给进程排序，而pidstat只显示实际使用了cpu的进程；htop和atop以不同颜色显示更直观 |
| 系统上下文切换 | vmstat | 除了上下文切换次数，还提供运行状态和不可中断状态进程的数量 |
| 进程上下文切换 | pidstat | 注意加上 -w 选项 |
| 软中断 | top、/proc/softirqs、mpstat | top提供软中断cpu使用率；/proc/softirqs和mpstat提供各种软中断在每个CPU上运行的累计次数 |
| 硬中断 | vmstat、/proc/interrupts | vmstat提供总的中断次数；/proc/interrupts提供各种中断在每个CPU上运行的累计次数 |
| 网络 | dstat、sar、tcpdump | dstat和sar提供总的网络接收和发送情况；tcpdump则是动态抓取正在进行的网络通信情况 |
| IO | dstat、sar | dstat和sar都提供了IO的总体情况 |
| CPU个数 | lscpu、/proc/cpuinfo | lscpu更简单 |
| 事件分析 | perf、execsnoop | perf可以用来分析CPU的缓存以及内核调用链；execsnoop用来监控短时进程 |

### 工具的指标
| 性能工具 | CPU性能指标 |
| ------ | ------ |
| uptime | 平均负载 |
| top | 平均负载、运行队列、整体的CPU使用率以及每个进程的状态和CPU使用率 |
| htop | top增强版，以不同颜色区分不同类型的进程，更直观 |
| atop | CPU、内存、磁盘和网络等各种资源的全面监控 |
| vmstat | 系统整体的CPU使用率、上下文切换次数、中断次数，还包括运行中的进程数量、不可中断状态的进程数量 |
| mpstat | 每个CPU的使用率和软中断次数 |
| pidstat | 进程和线程的CPU使用率、中断上下文次数 |
| /proc/softirqs | 软中断类型和在每个CPU上累计的中断次数 |
| /proc/interrupts | 中断类型和在每个CPU上累计的中断次数 |
| ps | 每个进程的状态和CPU使用率 |
| pstree | 进程的父子关系 |
| dstat | 系统整体的CPU、内存、磁盘和IO状态 |
| sar | 系统整体的CPU使用率 |
| strace | 进程的系统调用 |
| perf | CPU性能事件剖析，如调用链分析、CPU缓存、CPU调度等 |
| execsnoop | 监控短时进程 |
## 内存性能分析工具
### 工具
| 性能指标 | 工具 | 说明 |
| ------ | ------ | ------ |
| 系统已用、可用、剩余内存 | free、vmstat、sar、/proc/meminfo | |
| 进程虚拟内存、常驻内存、共享内存 | top、ps |  |
| 进程内存分布 | pmap |  |
| 进程swap换出内存 | top、/proc/pid/status |  |
| 进程缺页异常 | ps、top |  |
| 系统换页情况 | sar |  |
| 缓存/缓冲区用量 | free、vmstat、sar、cachestat |  |
| 缓存/缓冲区命中率 | cachetop |  |
| Swap已用空间和剩余空间 | free、sar |  |
| Swap换入换出 | vmstat |  |
| 内存泄漏检测 | memleak、valgrind |  |
| 指定文件的缓存大小 | pcstat |  |
### 分析思路
1. 先用free和top，查看系统整体的内存使用情况。
2. 再用vmstat和pidstat，查看一段时间的趋势，从而判断出内存问题的类型。
3. 最后进行详细分析，比如内存分配分析、缓存/缓冲区分析、具体进程的内存使用分析等。

## 磁盘性能分析工具
### 指标
* 使用率：磁盘处理I/O请求的百分比，过高的使用率通常意味着磁盘I/O存在性能瓶颈。
* IOPS：每秒的I/O请求数。
* 响应时间：是指从发出I/O请求到收到响应的间隔时间，包括排队等待时间。
* 饱和度：
* 吞吐量：每秒的I/O请求大小。
### 性能测试工具
* fio

### 分析工具
| 性能指标 | 工具 | 说明 |
| ------ | ------ | ------ |
| 文件系统空间容量、使用量以及剩余空间 | df |  |
| 索引节点容量、使用量以及剩余量 | df -i |  |
| 页缓存和可回收slab缓存 | /proc/meminfo、sar和vmstat | sar -r |
| 缓冲区 | /proc/meminfo、sar和vmstat | sar -r |
| 目录项、索引节点以及文件系统的缓存 | /proc/slabinfo、slabtop | slabtop更直观 |
| 磁盘I/O使用率、IOPS、吞吐量、响应时间、I/O平均大小以及等待队列长度 | iostat、sar和dstat | 使用iostat -d -x或者sar -d 选项 |
| 进程I/O大小以及I/O延迟 | pidstat、iotop | 使用pidstat -d选项 |
| 块设备I/O事件跟踪 | blktrace | 示例：blktrace -d /dev/sda -o- | blkparse -i- |
| 进程I/O系统调用跟踪 | strace | 通过系统调用跟踪进程的I/O |
| 进程块设备I/O大小跟踪 | biosnoop、biotop |  |

## 网络性能
### 指标
* 带宽
* PPS
* 吞吐量
* 延迟
### 分析工具
| 性能指标 | 工具 | 说明 |
| ------ | ------ | ------ |
| 吞吐量(BPS) | sar、nethogs、iftop | 分别可以查看网络接口、进程以及IP地址的网络吞吐量 |
| PPS | sar、/proc/net/dev | 查看网络接口的PPS |
| 连接数 | netstat、ss | 查看网络连接数 |
| 延迟 | ping、hping3 | 通过ICMP、TCP等测试网络延迟 |
| 连接跟踪数 | conntrack | 查看和管理连接跟踪状况 |
| 路由 | mtr、route和traceroute | 查看路由并测试链路信息 |
| DNS | dig、nslookup | 排查DNS解析问题 |
| 防火墙和NAT | iptables | 配置和管理防火墙及NAT规则 |
| 网卡功能 | ethtool | 查看和配置网络接口的功能 |
| 抓包 | tcpdump、wireshark | 抓包分析网络流量 |
| 内核协议栈跟踪 | bcc、systemtap | 动态跟踪内核协议栈的行为 |

| 性能工具 | 主要功能 |
| ------ | ------ |
| ifconfig、ip | 配置和查看网络接口 |
| ss | 查看网络连接数 |
| sar、/proc/net/dev/sys/class/net/eth0/statistics/ | 查看网络接口的网络收发情况 |
| nethogs | 查看进程的网络收发情况 |
| iftop | 查看IP的网络收发情况 |
| ethtool | 查看和配置网络接口 |
| conntrack | 查看和管理连接跟踪状况 |
| nslookup、dig | 排查DNS解析问题 |
| mtr、route、traceroute | 查看路由并测试链路信息 |
| ping、hping3 | 测试网络延迟 |
| tcpdump | 网络抓包工具 |
| wireshark | 网络抓包和图形界面分析工具 |
| iptables | 配置和管理防火墙及NAT规则 |
| perf | 剖析内核协议栈的性能 |
| systemtap | 动态追踪内核协议栈的行为 |
| bcc | 动态追踪内核协议栈的行为 |

### 性能测试
* 网络层：关注的是网络包的处理能力，即PPS。Linux内核自带的工具pktgen可以用来测试网络层的性能。
* 传输层：关注的是TCP/UDP的性能，可以通过工具iperf3、netperf等来测试。
* 应用层：关注的是并发连接数、qps、处理延迟等，可以通过wrk、Jmeter、ab等工具来模拟用户的负载进行测试。
