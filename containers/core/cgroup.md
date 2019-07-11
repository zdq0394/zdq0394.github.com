# Linux Control Group
Linux Namespace提供了一种对系统资源进行**隔离**的方法；Linux Control Group(CGroup)提供了一种对系统资源进行**限制**的方法。
Linux CGroup不但可以**限制**系统资源，还可以对系统资源进行**计量**、**优先级**和**控制**。
## Cgroup子系统
针对不同的资源，Cgroup提供了不同的子系统：
可以通过命令
```sh
cat /proc/cgroups 
```
来查看。
```sh
#subsys_name	hierarchy	num_cgroups	enabled
cpuset	11	38	1
cpu	2	160	1
cpuacct	2	160	1
blkio	10	160	1
memory	9	447	1
devices	5	160	1
freezer	7	38	1
net_cls	4	38	1
perf_event	12	38	1
net_prio	4	38	1
hugetlb	3	38	1
pids	8	160	1
rdma	6	1	1
```

在Centos系统中，cgroup文件系统默认mount到/sys/fs/cgroup。
```sh
ll /sys/fs/cgroup/
total 0
dr-xr-xr-x 2 root root  0 Jul 11 13:44 blkio
lrwxrwxrwx 1 root root 11 Jul  9 09:53 cpu -> cpu,cpuacct
lrwxrwxrwx 1 root root 11 Jul  9 09:53 cpuacct -> cpu,cpuacct
dr-xr-xr-x 2 root root  0 Jul 11 13:44 cpu,cpuacct
dr-xr-xr-x 2 root root  0 Jul 11 13:44 cpuset
dr-xr-xr-x 4 root root  0 Jul 11 13:44 devices
dr-xr-xr-x 2 root root  0 Jul 11 13:44 freezer
dr-xr-xr-x 2 root root  0 Jul 11 13:44 hugetlb
dr-xr-xr-x 2 root root  0 Jul 11 13:44 memory
lrwxrwxrwx 1 root root 16 Jul  9 09:53 net_cls -> net_cls,net_prio
dr-xr-xr-x 2 root root  0 Jul 11 13:44 net_cls,net_prio
lrwxrwxrwx 1 root root 16 Jul  9 09:53 net_prio -> net_cls,net_prio
dr-xr-xr-x 2 root root  0 Jul 11 13:44 perf_event
dr-xr-xr-x 2 root root  0 Jul 11 13:44 pids
dr-xr-xr-x 2 root root  0 Jul 11 13:44 rdma
dr-xr-xr-x 4 root root  0 Jul 11 13:44 systemd
```

其中，各个子系统是相对独立，分别控制不同种类的资源。

如下示例中，cpu和memory控制组分别从CPU和memory两个方面对容器**pod87c850db-76cc-11e9-b277-5254000aaae3/41675c9ebd96e64d40f67b85c4d80cbc8006d3de6f5d3b91f3c8785c5a3de9bd**进行资源限制。
```sh
# ll /sys/fs/cgroup/cpu/kubepods/besteffort/pod87c850db-76cc-11e9-b277-5254000aaae3/41675c9ebd96e64d40f67b85c4d80cbc8006d3de6f5d3b91f3c8785c5a3de9bd
total 0
-rw-r--r-- 1 root root 0 Jul  8 16:40 cgroup.clone_children
-rw-r--r-- 1 root root 0 May 20 14:19 cgroup.procs
-r--r--r-- 1 root root 0 Jul  8 16:40 cpuacct.stat
-rw-r--r-- 1 root root 0 Jul  8 16:40 cpuacct.usage
-r--r--r-- 1 root root 0 Jul  8 16:40 cpuacct.usage_all
-r--r--r-- 1 root root 0 Jul  8 16:40 cpuacct.usage_percpu
-r--r--r-- 1 root root 0 Jul  8 16:40 cpuacct.usage_percpu_sys
-r--r--r-- 1 root root 0 Jul  8 16:40 cpuacct.usage_percpu_user
-r--r--r-- 1 root root 0 Jul  8 16:40 cpuacct.usage_sys
-r--r--r-- 1 root root 0 Jul  8 16:40 cpuacct.usage_user
-rw-r--r-- 1 root root 0 Jul  8 16:40 cpu.cfs_period_us
-rw-r--r-- 1 root root 0 Jul  8 16:40 cpu.cfs_quota_us
-rw-r--r-- 1 root root 0 Jul  8 16:40 cpu.rt_period_us
-rw-r--r-- 1 root root 0 Jul  8 16:40 cpu.rt_runtime_us
-rw-r--r-- 1 root root 0 May 20 14:19 cpu.shares
-r--r--r-- 1 root root 0 Jul  8 16:40 cpu.stat
-rw-r--r-- 1 root root 0 Jul  8 16:40 notify_on_release
-rw-r--r-- 1 root root 0 Jul  8 16:40 tasks

# ll /sys/fs/cgroup/memory/kubepods/besteffort/pod87c850db-76cc-11e9-b277-5254000aaae3/41675c9ebd96e64d40f67b85c4d80cbc8006d3de6f5d3b91f3c8785c5a3de9bd
total 0
-rw-r--r-- 1 root root 0 Jul  8 16:40 cgroup.clone_children
--w--w--w- 1 root root 0 Jul  8 16:40 cgroup.event_control
-rw-r--r-- 1 root root 0 May 20 14:19 cgroup.procs
-rw-r--r-- 1 root root 0 Jul  8 16:40 memory.failcnt
--w------- 1 root root 0 Jul  8 16:40 memory.force_empty
-rw-r--r-- 1 root root 0 Jul  8 16:40 memory.kmem.failcnt
-rw-r--r-- 1 root root 0 Jul  8 16:40 memory.kmem.limit_in_bytes
-rw-r--r-- 1 root root 0 Jul  8 16:40 memory.kmem.max_usage_in_bytes
-r--r--r-- 1 root root 0 Jul  8 16:40 memory.kmem.slabinfo
-rw-r--r-- 1 root root 0 Jul  8 16:40 memory.kmem.tcp.failcnt
-rw-r--r-- 1 root root 0 Jul  8 16:40 memory.kmem.tcp.limit_in_bytes
-rw-r--r-- 1 root root 0 Jul  8 16:40 memory.kmem.tcp.max_usage_in_bytes
-r--r--r-- 1 root root 0 Jul  8 16:40 memory.kmem.tcp.usage_in_bytes
-r--r--r-- 1 root root 0 Jul  8 16:40 memory.kmem.usage_in_bytes
-rw-r--r-- 1 root root 0 Jul  8 16:40 memory.limit_in_bytes
-rw-r--r-- 1 root root 0 Jul  8 16:40 memory.max_usage_in_bytes
-rw-r--r-- 1 root root 0 Jul  8 16:40 memory.memsw.failcnt
-rw-r--r-- 1 root root 0 Jul  8 16:40 memory.memsw.limit_in_bytes
-rw-r--r-- 1 root root 0 Jul  8 16:40 memory.memsw.max_usage_in_bytes
-r--r--r-- 1 root root 0 Jul  8 16:40 memory.memsw.usage_in_bytes
-rw-r--r-- 1 root root 0 Jul  8 16:40 memory.move_charge_at_immigrate
-r--r--r-- 1 root root 0 Jul  8 16:40 memory.numa_stat
-rw-r--r-- 1 root root 0 Jul  8 16:40 memory.oom_control
---------- 1 root root 0 Jul  8 16:40 memory.pressure_level
-rw-r--r-- 1 root root 0 Jul  8 16:40 memory.soft_limit_in_bytes
-r--r--r-- 1 root root 0 Jul  8 16:40 memory.stat
-rw-r--r-- 1 root root 0 Jul  8 16:40 memory.swappiness
-r--r--r-- 1 root root 0 Jul  8 16:40 memory.usage_in_bytes
-rw-r--r-- 1 root root 0 Jul  8 16:40 memory.use_hierarchy
-rw-r--r-- 1 root root 0 Jul  8 16:40 notify_on_release
-rw-r--r-- 1 root root 0 Jul  8 16:40 tasks
```

## Cgroup使用
### 创建group并对资源进行限制
* 在任何subsystem下创建子目录，比如在/sys/fs/cgroup/cpu下创建mytest；然后将需要进行限制的进程ID加入到mytest/tasks中，并对资源进行一定的限制。
```sh
# mkdir mytest
# cd mytest/
# ll
total 0
-rw-r--r-- 1 root root 0 Jul 11 13:53 cgroup.clone_children
-rw-r--r-- 1 root root 0 Jul 11 13:53 cgroup.procs
-r--r--r-- 1 root root 0 Jul 11 13:53 cpuacct.stat
-rw-r--r-- 1 root root 0 Jul 11 13:53 cpuacct.usage
-r--r--r-- 1 root root 0 Jul 11 13:53 cpuacct.usage_all
-r--r--r-- 1 root root 0 Jul 11 13:53 cpuacct.usage_percpu
-r--r--r-- 1 root root 0 Jul 11 13:53 cpuacct.usage_percpu_sys
-r--r--r-- 1 root root 0 Jul 11 13:53 cpuacct.usage_percpu_user
-r--r--r-- 1 root root 0 Jul 11 13:53 cpuacct.usage_sys
-r--r--r-- 1 root root 0 Jul 11 13:53 cpuacct.usage_user
-rw-r--r-- 1 root root 0 Jul 11 13:53 cpu.cfs_period_us
-rw-r--r-- 1 root root 0 Jul 11 13:53 cpu.cfs_quota_us
-rw-r--r-- 1 root root 0 Jul 11 13:53 cpu.rt_period_us
-rw-r--r-- 1 root root 0 Jul 11 13:53 cpu.rt_runtime_us
-rw-r--r-- 1 root root 0 Jul 11 13:53 cpu.shares
-r--r--r-- 1 root root 0 Jul 11 13:53 cpu.stat
-rw-r--r-- 1 root root 0 Jul 11 13:53 notify_on_release
-rw-r--r-- 1 root root 0 Jul 11 13:53 tasks
```
### 示例
1. 准备工作
如下脚本将往设备/dev/tty持续性的写如数据：

```sh
#!/bin/bash
while :
do
    echo "print line" > /dev/tty
    sleep 3
done
```

将脚本保存为mytest.sh。
2. 创建devices资源的cgroup mytest
在/sys/fs/cgroup/devices/目录下创建croup——mytest（名字不重要）。

```sh
[/sys/fs/cgroup/devices/mytest]# ll
total 0
-rw-r--r-- 1 root root 0 Jul 11 13:58 cgroup.clone_children
-rw-r--r-- 1 root root 0 Jul 11 13:58 cgroup.procs
--w------- 1 root root 0 Jul 11 13:58 devices.allow
--w------- 1 root root 0 Jul 11 14:02 devices.deny
-r--r--r-- 1 root root 0 Jul 11 13:58 devices.list
-rw-r--r-- 1 root root 0 Jul 11 13:58 notify_on_release
-rw-r--r-- 1 root root 0 Jul 11 13:59 tasks
```

3. 查看/dev/tty的设备号

```sh
ll /dev/tty
crw-rw-rw- 1 root tty 5, 0 Jul 11 14:00 /dev/tty
```

然后将该设备加入devices.deny
```sh
echo "c 5:0 w" > devices.deny
```
4. 执行1中保存的脚本
程序正常执行
```sh
# ./mytest.sh 
print line
print line
print line
print line
print line
print line
print line
print line
```

5. 查看程序的pid，并将pid加入到mytest/tasks中
```sh
echo "8439" > mytest/tasks
```
此时观察程序输出，发现访问/dev/tty设备失败（Operation not permitted）:

```sh
# ./mytest.sh 
print line
print line
print line
print line
print line
print line
print line
./mytest.sh: line 5: /dev/tty: Operation not permitted
./mytest.sh: line 5: /dev/tty: Operation not permitted
./mytest.sh: line 5: /dev/tty: Operation not permitted
./mytest.sh: line 5: /dev/tty: Operation not permitted
./mytest.sh: line 5: /dev/tty: Operation not permitted
./mytest.sh: line 5: /dev/tty: Operation not permitted
```
