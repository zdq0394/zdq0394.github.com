# Linux性能分析工具
## 压力模拟工具
stress是一个Linux系统压力测试工具。
也可以安装stree-ng进行更全面的测试。
```sh
stress --cpu 1 --timeout 600
stress -c 8 --timeout 600
stress-ng -i 1 --hdd 1 --timeout 600  #模拟磁盘IO
```
## CPU性能分析工具
| 性能指标 | 工具 | 说明 |
| ------ | ------ | ------ |
| 平均负载 | uptime、top  | uptime最简单；top提供了更全的指标 |
| 系统整体CPU使用率 | top、mpstat、vmstat、sar、/proc/stat | top、vmstat和mpstat只可以动态查看，而sar还可以记录历史数；/proc/stat是其它性能工具的数据来源 |
| 进程CPU使用率 | top、pidstat、ps、htop、atop | top和ps可以按cpu使用率给进程排序，而pidstat只显示实际使用了cpu的进程；htop和atop以不同颜色显示更直观 |
| 系统上下文切换 | vmstat | 除了上下文切换次数，还提供运行状态和不可中断状态进程的数量 |
| 进程上下文切换 | pidstat | 注意加上 -w 选项 |
| 软终端 | top、/proc/softirqs、mpstat | top提供软中断cpu使用率；/proc/softirqs和mpstat提供各种软中断在每个CPU上运行的累计次数 |
| 硬中断 | vmstat、/proc/interrupts | vmstat提供总的中断次数；/proc/interrupts提供各种中断在每个CPU上运行的累计次数 |
| 网络 | dstat、sar、tcpdump | dstat和sar提供总的网络接收和发送情况；tcpdump则是动态抓取正在进行的网络通信情况 |
| IO | dstat、sar | dstat和sar都提供了IO的总体情况 |
| CPU个数 | lscpu、/proc/cpuinfo | lscpu更简单 |
| 事件分析 | perf、execsnoop | perf可以用来分析CPU的缓存以及内核调用链；execsnoop用来监控短时进程 |

## 内存性能分析工具
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

## 磁盘性能分析工具
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

## 网络性能分析工具
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