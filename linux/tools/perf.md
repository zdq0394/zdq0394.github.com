# perf
## 介绍
perf——Performance analysis tools for Linux，是Linux的性能分析工具。

Perf基于事件采样原理，以性能事件为基础，支持针对处理器相关性能指标与操作系统相关性能指标的性能剖析。

常用于性能瓶颈的查找与热点代码的定位。

## 常用子工具
### perf list
用来查看perf所支持的性能事件，有软件的也有硬件的。
下表显示了其中一部分。
```sh
# perf list

List of pre-defined events (to be used in -e):

  branch-instructions OR branches                    [Hardware event]
  branch-misses                                      [Hardware event]
  bus-cycles                                         [Hardware event]
  cache-misses                                       [Hardware event]
  cache-references                                   [Hardware event]
  cpu-cycles OR cycles                               [Hardware event]
  instructions                                       [Hardware event]
  ref-cycles                                         [Hardware event]

  alignment-faults                                   [Software event]
  context-switches OR cs                             [Software event]
  cpu-clock                                          [Software event]
  cpu-migrations OR migrations                       [Software event]
  dummy                                              [Software event]
  emulation-faults                                   [Software event]
  major-faults                                       [Software event]
  minor-faults                                       [Software event]
  page-faults OR faults                              [Software event]
  task-clock                                         [Software event]

```
### perf top
对于一个指定的性能事件(默认是CPU周期)，显示消耗最多的函数或指令。

perf top主要用于实时分析各个函数在某个性能事件上的热度，能够快速的定位热点函数，包括应用程序函数、模块函数与内核函数，甚至能够定位到热点指令。

默认的性能事件为cpu cycles。

常用命令行参数：
* -e event：指明要分析的性能事件。
* -p pid：Profile events on existing Process ID (comma sperated list)。仅分析目标进程及其创建的线程。
* -k path：Path to vmlinux。Required for annotation functionality。带符号表的内核映像所在的路径。
* -K：不显示属于内核或模块的符号。
* -U：不显示属于用户态程序的符号。
* -d n：界面的刷新周期，默认为2s，因为perf top默认每2s从mmap的内存区域读取一次性能数据。
* -g：得到函数的调用关系图。
### perf stat
用于分析指定程序的性能概况。

比如：分析ls命令的性能概况：
```sh
perf stat ls
```
### perf record
收集采样信息，并将其记录在数据文件中。随后可以通过其它工具(perf-report)对数据文件进行分析，结果类似于perf-top的结果。
### perf report
读取perf record创建的数据文件，并给出热点分析结果。