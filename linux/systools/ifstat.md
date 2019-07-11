# ifstat
## 使用方法
`ifstat`是一个统计`网络接口活动状态`的工具。

使用工具`netstat -i`可以达到几乎相同的效果。
```sh
Usage: ifstat [OPTION] [ PATTERN [ PATTERN ] ]
   -h, --help		this message
   -a, --ignore	ignore history
   -d, --scan=SECS	sample every statistics every SECS
   -e, --errors	show errors
   -n, --nooutput	do history only
   -r, --reset		reset history
   -s, --noupdate	don;t update history
   -t, --interval=SECS	report average over the last SECS
   -V, --version	output version information
   -z, --zeros		show entries with zero activity
```

## 例子
```sh
[root@SCSP01815 ~]# ifstat
#kernel
Interface        RX Pkts/Rate    TX Pkts/Rate    RX Data/Rate    TX Data/Rate  
                 RX Errs/Drop    TX Errs/Drop    RX Over/Rate    TX Coll/Rate  
lo                   163 0           163 0         12004 0         12004 0      
                       0 0             0 0             0 0             0 0      
ens9f0            284776 0         14596 0        83931K 0         1834K 0      
                       0 0             0 0             0 0             0 0      
ens9f1            248951 0         4365K 0        75592K 0         2258M 0      
                       0 0             0 0             0 0             0 0      
bond1             533727 0         4379K 0       159524K 0         2260M 0      
```