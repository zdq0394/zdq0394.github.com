# iftop
`iftop`是监控网卡`实时流量`的工具
## 使用方法
```sh
iftop: display bandwidth usage on an interface by host

Synopsis: iftop -h | [-npblNBP] [-i interface] [-f filter code]
                               [-F net/mask] [-G net6/mask6]

   -h                  display this message
   -n                  don't do hostname lookups
   -N                  don't convert port numbers to services
   -p                  run in promiscuous mode (show traffic between other
                       hosts on the same network segment)
   -b                  don't display a bar graph of traffic
   -B                  Display bandwidth in bytes
   -i interface        listen on named interface
   -f filter code      use filter code to select packets to count
                       (default: none, but only IP packets are counted)
   -F net/mask         show traffic flows in/out of IPv4 network
   -G net6/mask6       show traffic flows in/out of IPv6 network
   -l                  display and count link-local IPv6 traffic (default: off)
   -P                  show ports as well as hosts
   -m limit            sets the upper limit for the bandwidth scale
   -c config file      specifies an alternative configuration file
   -t                  use text interface without ncurses

   Sorting orders:
   -o 2s                Sort by first column (2s traffic average)
   -o 10s               Sort by second column (10s traffic average) [default]
   -o 40s               Sort by third column (40s traffic average)
   -o source            Sort by source address
   -o destination       Sort by destination address

   The following options are only available in combination with -t
   -s num              print one single text output afer num seconds, then quit
   -L num              number of lines to print
```

### 中间切换指令
* 按h切换是否显示帮助
* 按n切换显示本机的IP或主机名
* 按s切换是否显示本机的host信息
* 按d切换是否显示远端目标主机的host信息
* 按t切换显示格式为2行/1行/只显示发送流量/只显示接收流量
* 按N切换显示端口号或端口服务名称
* 按S切换是否显示本机的端口信息
* 按D切换是否显示远端目标主机的端口信息
* 按p切换是否显示端口信息
* 按P切换暂停/继续显示
* 按b切换是否显示平均流量图形条
* 按B切换计算2秒或10秒或40秒内的平均流量
* 按T切换是否显示每个连接的总流量
* 按l打开屏幕过滤功能，输入要过滤的字符，比如ip,按回车后，屏幕就只显示这个IP相关的流量信息
* 按L切换显示画面上边的刻度;刻度不同，流量图形条会有变化
* 按j或按k可以向上或向下滚动屏幕显示的连接记录
* 按1或2或3可以根据右侧显示的三列流量数据进行排序
* 按<根据左边的本机名或IP排序
* 按>根据远端目标主机的主机名或IP排序
* 按o切换是否固定只显示当前的连接
* 按f可以编辑过滤代码，这是翻译过来的说法，我还没用过这个
* 按!可以使用shell命令，这个没用过！没搞明白啥命令在这好用呢
* 按q退出监控

## 结果说明
* 中间的<= =>这两个左右箭头，表示的是流量的方向
* TX：发送流量
* RX：接收流量
* TOTAL：总流量
* Cumm：运行iftop到目前时间的总流量
* peak：流量峰值
* rates：分别表示过去`2s`、`10s`、`40s`的平均流量