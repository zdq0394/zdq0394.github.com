# iotop
`iotop`是一个用来监视`磁盘I/O使用状况`的top类工具，可监测到`哪一个程序`使用的磁盘IO的信息。
## 使用方法
```sh
Usage: /usr/sbin/iotop [OPTIONS]

DISK READ and DISK WRITE are the block I/O bandwidth used during the sampling
period. SWAPIN and IO are the percentages of time the thread spent respectively
while swapping in and waiting on I/O more generally. PRIO is the I/O priority at
which the thread is running (set using the ionice command).

Controls: left and right arrows to change the sorting column, r to invert the
sorting order, o to toggle the --only option, p to toggle the --processes
option, a to toggle the --accumulated option, i to change I/O priority, q to
quit, any other key to force a refresh.

Options:
  --version             show program's version number and exit
  -h, --help            show this help message and exit
  -o, --only            only show processes or threads actually doing I/O
  -b, --batch           non-interactive mode
  -n NUM, --iter=NUM    number of iterations before ending [infinite]
  -d SEC, --delay=SEC   delay between iterations [1 second]
  -p PID, --pid=PID     processes/threads to monitor [all]
  -u USER, --user=USER  users to monitor [all]
  -P, --processes       only show processes, not all threads
  -a, --accumulated     show accumulated I/O instead of bandwidth
  -k, --kilobytes       use kilobytes instead of a human friendly unit
  -t, --time            add a timestamp on each line (implies --batch)
  -q, --quiet           suppress some lines of header (implies --batch)
```

## 例子
```sh
Total DISK READ :	0.00 B/s | Total DISK WRITE :       0.00 B/s
Actual DISK READ:	0.00 B/s | Actual DISK WRITE:       0.00 B/s
  TID  PRIO  USER     DISK READ  DISK WRITE  SWAPIN     IO>    COMMAND                                                                                                                          
    1 be/4 root        0.00 B/s    0.00 B/s  0.00 %  0.00 % systemd --switched-root --system --deserialize 21
    2 be/4 root        0.00 B/s    0.00 B/s  0.00 %  0.00 % [kthreadd]
    3 be/4 root        0.00 B/s    0.00 B/s  0.00 %  0.00 % [ksoftirqd/0]
    5 be/0 root        0.00 B/s    0.00 B/s  0.00 %  0.00 % [kworker/0:0H]
    8 rt/4 root        0.00 B/s    0.00 B/s  0.00 %  0.00 % [migration/0]
    9 be/4 root        0.00 B/s    0.00 B/s  0.00 %  0.00 % [rcu_bh]
   10 be/4 root        0.00 B/s    0.00 B/s  0.00 %  0.00 % [rcuob/0]
   11 be/4 root        0.00 B/s    0.00 B/s  0.00 %  0.00 % [rcuob/1]
   12 be/4 root        0.00 B/s    0.00 B/s  0.00 %  0.00 % [rcuob/2]
   13 be/4 root        0.00 B/s    0.00 B/s  0.00 %  0.00 % [rcuob/3]
   14 be/4 root        0.00 B/s    0.00 B/s  0.00 %  0.00 % [rcuob/4]
   15 be/4 root        0.00 B/s    0.00 B/s  0.00 %  0.00 % [rcuob/5]
...
```