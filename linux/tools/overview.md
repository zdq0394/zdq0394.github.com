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
