# tcpdump
`tcpdump`是一个用于截取网络分组，并输出分组内容的工具，简单说就是数据包抓包工具。
`tcpdump`凭借强大的功能和灵活的截取策略，使其成为Linux系统下用于网络分析和问题排查的首选工具。

`tcpdump`可以将网络中传送的数据包的“头”完全截获下来提供分析。
它支持针对网络层、协议、主机、网络或端口的过滤，并提供and、or、not等逻辑语句来帮助你去掉无用的信息。
## 使用方法
* -i：指定监听的网络接口。
* -n：不把网络地址转换成名字。
* -nn：不进行端口名称的转换。
* -N：不输出主机名中的域名部分。
* -S：将tcp的序列号以绝对值形式输出，而不是相对值。
* -s：从每个分组中读取最开始的snaplen个字节，而不是默认的68个字节。

## 表达式
### 类型关键字
* host
* net
* port
### 传输方向
* src
* dst
* dst or src
* dst and src
### 协议
* fddi
* ip
* arp
* rarp
* tcp
* udp

## 举例
### 过滤主机
1. 抓取所有经过eth1，目的或者源地址是192.168.1.1的网络数据
tcpdump -i eth1 host 192.168.1.1
2. 指定源地址为192.168.1.1
tcpdump -i eth1 src host 192.168.1.1
3. 指定目的地为192.168.1.1
tcpdump -i eth1 dst host 192.168.1.1
### 过滤端口
1. 抓取所有经过eth1，目的或源端口是25的网络数据
tcpdump -i eth1 port 25
2. 指定源端口25
tcpdump -i eth1 src port 25
3. 指定目的端口25
tcpdump -i eth1 dst port 25
### 网络过滤
1. tcpdump -i eth1 net 192.168
2. tcpdump -i eth1 src net 192.168
3. tcpdump -i eth1 dst net 192.168
### 协议过滤
1. tcpdump -i eth1 tcp
2. tcpdump -i eth1 arp
3. tcpdump -i eth1 ip
4. tcpdump -i eth1 icmp
5. tcpdump -i eth1 udp
### 组合过滤
1. 抓取所有经过eth1，目的地址是192.168.1.254或192.168.1.200端口是80的TCP数据
tcpdump -i eth1 'tcp and port 80 and (dst host 192.168.1.254 or dst host 192.168.1.200)'
2. 抓取所有经过eth1，目标MAC地址是00:01:02:03:04:05的ICMP数据
tcpdump -i eth1 'icmp and ether dst host 00:01:02:03:04:05'
3. 抓取所有经过eth1，目的网络是192.168，但目的主机不是192.168.1.200的TCP数据
tcpdump -i eth1 'tcp and dst net 192.168 and (not dst host 192.168.1.200)'