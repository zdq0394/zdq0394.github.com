# 服务器丢包问题分析
## 基本思路
1. 通过netstat -i可以查看是否有链路层异常信息。
2. 通过netstat -s可以查看tcp/ip层的连接异常信息。
3. iptables是否对packet进行了限制。
    3.1. sysctl net.netfilter.nf_conntrack_max
    3.2. sysctl net.netfilter.nf_conntrack_count
    3.3. iptables -t filter -nvL