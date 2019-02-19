# Etcd调优
## 时间参数
### heartbeat-interval
Leader给Follower发送心跳的时间间隔。
一般设置为member间的round-trip time。
默认值是100ms
### election-timeout
当Follower没有及时收到leader的hearbeat时，经过多长时间进入选举阶段。
一般设置为member间的round-trip time的10倍。
默认值是1000ms;
最大可以设置为50s。

可以通过如下方式调整这两个值：
```sh
# Command line arguments:
# etcd --heartbeat-interval=100 --election-timeout=500

# Environment variables:
# ETCD_HEARTBEAT_INTERVAL=100 ETCD_ELECTION_TIMEOUT=500 etcd
```

## Snapshots
默认，每进行10000次更改，就会做一个snapshots。
如果etcd的内存和磁盘压力比较大，可以减小这个值。
```sh
# Command line arguments:
# etcd --snapshot-count=5000

# Environment variables:
# ETCD_SNAPSHOT_COUNT=5000 etcd
```

## 磁盘Disk
Etcd对磁盘的IO延迟特别敏感。

可以使用**ionice**命令给etcd进程一个比较高的磁盘优先级。
```sh
# best effort, highest priority
# ionice -c2 -n0 -p `pgrep etcd`
```

## 网络Network
如果leader大量的资源用来处理client请求，可能会来不及处理和follower之间的请求，从而导致集群问题。

可以设置peer流量的优先级高于client流量。
```sh
tc qdisc add dev eth0 root handle 1: prio bands 3
tc filter add dev eth0 parent 1: protocol ip prio 1 u32 match ip sport 2380 0xffff flowid 1:1
tc filter add dev eth0 parent 1: protocol ip prio 1 u32 match ip dport 2380 0xffff flowid 1:1
tc filter add dev eth0 parent 1: protocol ip prio 2 u32 match ip sport 2739 0xffff flowid 1:1
tc filter add dev eth0 parent 1: protocol ip prio 2 u32 match ip dport 2739 0xffff flowid 1:1
```
