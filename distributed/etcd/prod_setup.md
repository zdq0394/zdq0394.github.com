# 生产集群部署
**静态启动集群**需要每个成员提前知道其它成员的信息。在有些情况下，集群成员的IP无法提前获知，在这种情况下，集群需要借助外在的**服务发现**才能启动。

集群运行中，可以通过更改运行时配置添加或者移除节点。

下面分别介绍3中启动集群的方式：

* Static
* etcd Discovery
* DNS Discovery

我们计划构造如下的集群，配置如下：
| NAME| ADDRESS | HOSTNAME |
| ---- | :---- | :---- |
| infra0 | 10.0.1.10 | infra0.example.com |
| infra1 | 10.0.1.11 | infra1.example.com |
| infra2 | 10.0.1.12 | infra2.example.com |

## 静态启动
静态启动需要设置**initial-cluster**标志。设置方式有两中：

**静态环境变量**

```
ETCD_INITIAL_CLUSTER="infra0=http://10.0.1.10:2380,infra1=http://10.0.1.11:2380,infra2=http://10.0.1.12:2380"
ETCD_INITIAL_CLUSTER_STATE=new
```

**命令行参数**
```
--initial-cluster infra0=http://10.0.1.10:2380,infra1=http://10.0.1.11:2380,infra2=http://10.0.1.12:2380 \
--initial-cluster-state new
```

注意：**initial-cluster**中的URL参数是the advertised peer URLs，必需和**initial-advertise-peer-urls**一致。

## etcd发现




## DNS发现

