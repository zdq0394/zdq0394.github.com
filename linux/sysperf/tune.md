# 性能优化
## 网络性能优化
### TCP优化
| 优化方法 | 内核选项 | 参考设置 |
| ------ | ------ | ------ |
| 增大处于time_wait状态的连接的数量 | net.ipv4.tcp_max_tw_buckets | 1048576 |
| 增大连接跟踪表的大小 | net.netfilter.nf_conntrack_max | 1048576 |
| 缩短处于time_wait状态连接的超时时间 | net.ipv4.tcp_fin_timeout | 15 |
| 缩短连接跟踪表中处于time_wait状态连接的超时时间 | net.netfilter.nf_conntrack_tcp_timeout_time_wait | 30 |
| 允许time_wait状态连接占用的端口还可以用到新建的连接中 | net.ipv4.tcp_tw_reuse | 1 |
| 增大本地端口号的范围 | net.ipv4.ip_local_port_range | 10000 65000 |
| 增加系统和应用程序的最大文件描述符数 | fs.nr_open（系统），systemd配置文件中的LimitNOFIL（应用程序） | 1048576 |
| 增加半连接的最大数量 | net.ipv4.tcp_max_syn_backlog | 16384 |
| 开启SYN Cookies | net.ipv4.tcp_syncookies | 1 |
| 缩短发送keepalive探测包的间隔时间 | net.ipv4.tcp_keepalive_intvl | 30 |
| 减少keepalive探测失败后通知应用程序前的重试次数 | net.ipv4.tcp_keepalive_probes | 3 |
| 缩短最后一次数据包到keepalive探测包的间隔时间 | net.ipv4.tcp_keepalive_time | 600 |

### 网络层
从路由和转发的角度出发：
* 在需要转发的服务器中，比如把linux服务器作为路由器，net.ipv4.ip_forward = 1。
* 调整数据包的生存周期TTL，net.ipv4.ip_default_ttl = 64，增大该值会降低系统性能。
* 开启数据包的反向地址校验，net.ipv4.conf.eth0.rp_filter = 1，可以防止ip欺骗，并减少伪造IP带来的DDoS问题。
从分片的角度出发：
* 调整MTU
从ICMP的角度触发：
* 禁止icmp协议：net.ipv4.icmp_echo_ignore_all = 1。这样外部主机就无法通过ICMP来探测主机。
* 禁止icmp广播：net.ipv4.icmp_echo_ignore_broadcasts = 1。

## 磁盘IO优化
### 应用程序优化
1. 可以使用追加写代替随机写，减少寻址开销，加快I/O写的速度。
2. 可以借助缓存I/O，充分利用系统缓存，降低实际I/O的次数。
3. 在应用程序内部构建自己的缓存。
4. 在需要频繁读写同一块磁盘空间时，可以用mmap代替read/write，减少内存的拷贝次数。
5. 在需要同步写的场景中，尽量将写请求合并，而不是让每个请求都同步写入磁盘，可以用fsync()取代O_SYNC。
6. 在多个应用程序共享相同磁盘时，为了保证I/O不被某个应用程序完全占用，推荐使用cgroups的I/O子系统，来限制j进程/进程组的IOPS和吞吐量。
### 文件系统优化
1. 选择使用合适的文件系统：ext4和xfs。
2. 使用tune2fs调整文件系统的特性。
3. 优化文件系统的缓存。

### 磁盘优化
1. 使用性能更好的磁盘SSD。
2. 使用RAID，把多个磁盘组成一个逻辑磁盘。
3. 选择合适的调度算法：noop或者deadline。