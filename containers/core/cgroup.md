# Linux Control Group
Linux Namespace提供了一种对系统资源进行**隔离**的方法；Linux Control Group(CGroup)提供了一种对系统资源进行**限制**的方法。
Linux CGroup不但可以**限制**系统资源，还可以对系统资源进行**计量**、**优先级**和**控制**。
## Cgroup子系统
针对不同的资源，Cgroup提供了不同的子系统：
可以通过命令
```sh
cat /proc/cgroups 
```
来查看
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

各个子系统是相对独立，分别控制不同的资源。

比如如下示例中，cpu和memory控制组分别从CPU和内存两个方面对容器**pod87c850db-76cc-11e9-b277-5254000aaae3/41675c9ebd96e64d40f67b85c4d80cbc8006d3de6f5d3b91f3c8785c5a3de9bd**进行资源限制。
```sh
[root@compute2 /]# ll /sys/fs/cgroup/cpu/kubepods/besteffort/pod87c850db-76cc-11e9-b277-5254000aaae3/41675c9ebd96e64d40f67b85c4d80cbc8006d3de6f5d3b91f3c8785c5a3de9bd
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
[root@compute2 /]# ll /sys/fs/cgroup/memory/kubepods/besteffort/pod87c850db-76cc-11e9-b277-5254000aaae3/41675c9ebd96e64d40f67b85c4d80cbc8006d3de6f5d3b91f3c8785c5a3de9bd
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