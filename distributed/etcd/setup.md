# Setup a local cluster
## Local standalone cluster
运行一个standalone集群非常简单。只需一个命令：

```sh
$ ./etcd

```
etcd将监听localhost:2379端口。

可以通过**etcdctl**与集群交互：

```sh
# use API version 3
$ export ETCDCTL_API=3

$ ./etcdctl put foo bar
OK

$ ./etcdctl get foo
bar
```

## Local multi-member cluster
可以通过[Procfile](https://github.com/coreos/etcd/blob/master/Procfile**)可以运行一个**multi-member cluster**：

```
#install goreman program to control Profile-based applications.
$ go get github.com/mattn/goreman
$ goreman -f Procfile start

```
集群将启动，并监听**localhost:2379**，**localhost:22379**和**localhost:32379**端口。

可以通过**etcdctl**与集群交互：

```
# use API version 3
$ export ETCDCTL_API=3

$ etcdctl --write-out=table --endpoints=localhost:2379 member list
```
| ID | STATUS | NAME | PEER ADDRS | CLIENT ADDRS |
| ---- | :---- | :---- | :---- | :---- |
| 8211f1d0f64f3269 | started | infra1 | http://127.0.0.1:2380  | http://127.0.0.1:2379  |
| 91bc3c398fb3c146 | started | infra2 | http://127.0.0.1:22380 | http://127.0.0.1:22379 |
| fd422379fda50e48 | started | infra3 | http://127.0.0.1:32380 | http://127.0.0.1:32379 |

```
$ etcdctl put foo bar
OK
```

ETCD的容错功能可以通过杀掉其中一个member体验：

```
# kill etcd2
$ goreman run stop etcd2

$ etcdctl put key hello
OK

$ etcdctl get key
hello

# try to get key from the killed member
$ etcdctl --endpoints=localhost:22379 get key
2016/04/18 23:07:35 grpc: Conn.resetTransport failed to create client transport: connection error: desc = "transport: dial tcp 127.0.0.1:22379: getsockopt: connection refused"; Reconnecting to "localhost:22379"
Error:  grpc: timed out trying to connect

# restart the killed member
$ goreman run restart etcd2

# get the key from restarted member
$ etcdctl --endpoints=localhost:22379 get key
hello
```