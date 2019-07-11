# mpstat
## 介绍
mpstat是实时系统监控监控。
其报告与CPU相关的一些统计信息，这些信息存放在/proc/stat文件中。
在多CPUs的系统里，其不但能够查看所有CPU的平均状况，而且能够查看特定CPU的信息。
## 使用方法
### 所有CPU
```sh
mpstat  1 2
Linux 3.10.0-327.el7.x86_64 (scsp00348) 	04/25/2019 	_x86_64_	(32 CPU)

10:50:15 AM  CPU    %usr   %nice    %sys %iowait    %irq   %soft  %steal  %guest  %gnice   %idle
10:50:16 AM  all    0.22    0.00    0.09    0.00    0.00    0.00    0.00    0.00    0.00   99.69
10:50:17 AM  all    0.50    0.00    0.09    0.00    0.00    0.00    0.00    0.00    0.00   99.41
Average:     all    0.36    0.00    0.09    0.00    0.00    0.00    0.00    0.00    0.00   99.55

```

```sh
mpstat -P ALL 1 1
Linux 3.10.0-327.el7.x86_64 (scsp00348) 	04/25/2019 	_x86_64_	(32 CPU)

10:51:36 AM  CPU    %usr   %nice    %sys %iowait    %irq   %soft  %steal  %guest  %gnice   %idle
10:51:37 AM  all    0.34    0.00    0.19    0.00    0.00    0.00    0.00    0.00    0.00   99.47
10:51:37 AM    0    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00
10:51:37 AM    1    1.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00   99.00
10:51:37 AM    2    1.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00   99.00
10:51:37 AM    3    2.02    0.00    2.02    0.00    0.00    0.00    0.00    0.00    0.00   95.96
10:51:37 AM    4    1.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00   99.00
10:51:37 AM    5    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00
10:51:37 AM    6    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00
10:51:37 AM    7    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00
10:51:37 AM    8    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00
10:51:37 AM    9    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00
10:51:37 AM   10    1.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00   99.00
10:51:37 AM   11    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00
10:51:37 AM   12    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00
10:51:37 AM   13    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00
10:51:37 AM   14    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00
10:51:37 AM   15    0.00    0.00    0.99    0.00    0.00    0.00    0.00    0.00    0.00   99.01
10:51:37 AM   16    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00
10:51:37 AM   17    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00
10:51:37 AM   18    0.99    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00   99.01
10:51:37 AM   19    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00
10:51:37 AM   20    1.00    0.00    1.00    0.00    0.00    0.00    0.00    0.00    0.00   98.00
10:51:37 AM   21    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00
10:51:37 AM   22    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00
10:51:37 AM   23    3.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00   97.00
10:51:37 AM   24    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00
10:51:37 AM   25    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00
10:51:37 AM   26    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00
10:51:37 AM   27    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00
10:51:37 AM   28    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00
10:51:37 AM   29    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00
10:51:37 AM   30    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00
10:51:37 AM   31    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00

Average:     CPU    %usr   %nice    %sys %iowait    %irq   %soft  %steal  %guest  %gnice   %idle
Average:     all    0.34    0.00    0.19    0.00    0.00    0.00    0.00    0.00    0.00   99.47
Average:       0    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00
Average:       1    1.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00   99.00
Average:       2    1.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00   99.00
Average:       3    2.02    0.00    2.02    0.00    0.00    0.00    0.00    0.00    0.00   95.96
Average:       4    1.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00   99.00
Average:       5    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00
Average:       6    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00
Average:       7    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00
Average:       8    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00
Average:       9    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00
Average:      10    1.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00   99.00
Average:      11    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00
Average:      12    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00
Average:      13    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00
Average:      14    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00
Average:      15    0.00    0.00    0.99    0.00    0.00    0.00    0.00    0.00    0.00   99.01
Average:      16    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00
Average:      17    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00
Average:      18    0.99    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00   99.01
Average:      19    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00
Average:      20    1.00    0.00    1.00    0.00    0.00    0.00    0.00    0.00    0.00   98.00
Average:      21    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00
Average:      22    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00
Average:      23    3.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00   97.00
Average:      24    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00
Average:      25    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00
Average:      26    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00
Average:      27    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00
Average:      28    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00
Average:      29    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00
Average:      30    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00
Average:      31    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00
```

### 特定CPU
-P CPUID：指定特定CPU
```sh
mpstat -P 9 1 1
Linux 3.10.0-327.el7.x86_64 (scsp00348) 	04/25/2019 	_x86_64_	(32 CPU)

10:52:05 AM  CPU    %usr   %nice    %sys %iowait    %irq   %soft  %steal  %guest  %gnice   %idle
10:52:06 AM    9    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00
Average:       9    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00
```