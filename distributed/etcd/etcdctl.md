# 命令etcdctl用法V3
命令行工具`etcdctl`是最常用的与etcd集群交互的工具。

默认情况下，etcdctl使用**v2**和集群进行交互。

如果要使用**v3**版本，可以显式的设置环境变量。
```sh
export ETCDCTL_API=3
```

## 版本号查看
``` bash
# etcdctl version
etcdctl version: 3.2.15
API version: 3.2
```
## lease使用
### grant
``` sh
# etcdctl lease grant 100
lease 4d3c62b939c83167 granted with TTL(100s)
```
在写入一个kv的时候可以绑定一个lease，如果一个key被绑定了一个lease，那么这个key就具有和lease一样的声明周期。
当lease过期删除的时候，所有绑定这个lease的kv对都会被删除。
```sh
# etcdctl put --lease=4d3c62b939c83167 foo bar
OK
```
### revoke
```
# etcdctl lease revoke 4d3c62b939c83167
lease 4d3c62b939c83167 revoked
```
当一个lease被回收的时候，所有绑定该lease的kv都会被删除。

### keep-alive
lease续约机制
```sh
# etcdctl lease keep-alive 4d3c62b939c83167
lease 4d3c62b939c83167 keepalived with TTL(100)
lease 4d3c62b939c83167 keepalived with TTL(100)
lease 4d3c62b939c83167 keepalived with TTL(100)
```
### timetolive
查看lease的TTL和剩余时间信息
```sh
# etcdctl lease timetolive 4d3c62b939c83167
lease 4d3c62b939c83167 granted with TTL(100s), remaining(66s)
```
查看lease绑定的keys
```sh
# etcdctl lease timetolive --keys 4d3c62b939c83167
lease 4d3c62b939c83167 granted with TTL(100s), remaining(62s), attached keys([zoo2 zoo1])
```

## Write Keys
每个key都会通过Raft协议被复制到etcd集群的所有成员节点，从而达到一致性和可靠性。
``` sh
# etcdctl put foo bar
OK
```

## Read Keys
查看foo及其value。
``` sh
# etcdctl get foo
foo
bar
```
查看所有以foo开头的kv对，最多显示2个。
``` sh
# etcdctl get --prefix --limit=2 foo
foo
bar
foo1
bar1
```

查看某个版本以前的数据。
``` sh
# etcdctl get --prefix foo # access the most recent versions of keys
foo
bar_new
foo1
bar1_new

$ etcdctl get --prefix --rev=4 foo # access the versions of keys at revision 4
foo
bar_new
foo1
bar1

$ etcdctl get --prefix --rev=3 foo # access the versions of keys at revision 3
foo
bar
foo1
bar1
```

## Watch Keys
监视数据
``` sh
# etcdctl watch foo
# in another terminal: etcdctl put foo bar
PUT
foo
bar
```
监视从某个版本以来所有的数据操作
``` sh
# watch for changes on key `foo` since revision 2
# etcdctl watch --rev=2 foo
PUT
foo
bar
PUT
foo
bar_new
```

## Del keys
删除某个key。
```sh
# etcdctl del foo
1 # one key is deleted
```