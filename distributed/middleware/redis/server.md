# Redis服务器
Redis服务器命令主要是用于管理redis服务。
## 实例
``` sh
127.0.0.1:6379> info
# Server
redis_version:4.0.1
redis_git_sha1:00000000
redis_git_dirty:0
redis_build_id:98e4d2ebc89f5f7c
redis_mode:standalone
os:Linux 3.10.0-327.el7.x86_64 x86_64
arch_bits:64
multiplexing_api:epoll
atomicvar_api:atomic-builtin
gcc_version:4.8.5
process_id:2059
run_id:194c9fdc62648cc5ab972a9f0a9caa9098c42a82
tcp_port:6379
uptime_in_seconds:15985
uptime_in_days:0
hz:10
lru_clock:14333567
executable:/root/redis-4.0.1/src/redis-server
config_file:/root/redis-4.0.1/redis.conf

# Clients
connected_clients:2
client_longest_output_list:0
client_biggest_input_buf:0
blocked_clients:0

# Memory
used_memory:865016
used_memory_human:844.74K
used_memory_rss:8093696
used_memory_rss_human:7.72M
used_memory_peak:865016
used_memory_peak_human:844.74K
used_memory_peak_perc:100.12%
used_memory_overhead:832592
used_memory_startup:765616
used_memory_dataset:32424
used_memory_dataset_perc:32.62%
total_system_memory:8203108352
total_system_memory_human:7.64G
used_memory_lua:40960
used_memory_lua_human:40.00K
maxmemory:0
maxmemory_human:0B
maxmemory_policy:noeviction
mem_fragmentation_ratio:9.36
mem_allocator:jemalloc-4.0.3
active_defrag_running:0
lazyfree_pending_objects:0

# Persistence
loading:0
rdb_changes_since_last_save:0
rdb_bgsave_in_progress:0
rdb_last_save_time:1524281746
rdb_last_bgsave_status:ok
rdb_last_bgsave_time_sec:0
rdb_current_bgsave_time_sec:-1
rdb_last_cow_size:6561792
aof_enabled:0
aof_rewrite_in_progress:0
aof_rewrite_scheduled:0
aof_last_rewrite_time_sec:-1
aof_current_rewrite_time_sec:-1
aof_last_bgrewrite_status:ok
aof_last_write_status:ok
aof_last_cow_size:0

# Stats
total_connections_received:14
total_commands_processed:74
instantaneous_ops_per_sec:0
total_net_input_bytes:3548
total_net_output_bytes:45074
instantaneous_input_kbps:0.00
instantaneous_output_kbps:0.00
rejected_connections:0
sync_full:0
sync_partial_ok:0
sync_partial_err:0
expired_keys:0
evicted_keys:0
keyspace_hits:36
keyspace_misses:4
pubsub_channels:1
pubsub_patterns:0
latest_fork_usec:861
migrate_cached_sockets:0
slave_expires_tracked_keys:0
active_defrag_hits:0
active_defrag_misses:0
active_defrag_key_hits:0
active_defrag_key_misses:0

# Replication
role:master
connected_slaves:0
master_replid:5b9e3538e6f8e6d26a9a90448f554b7a6a17c64a
master_replid2:0000000000000000000000000000000000000000
master_repl_offset:0
second_repl_offset:-1
repl_backlog_active:0
repl_backlog_size:1048576
repl_backlog_first_byte_offset:0
repl_backlog_histlen:0

# CPU
used_cpu_sys:9.71
used_cpu_user:4.56
used_cpu_sys_children:0.03
used_cpu_user_children:0.00

# Cluster
cluster_enabled:0

# Keyspace
db0:keys=9,expires=0,avg_ttl=0
```

## Redis服务器命令
* BGREWRITEAOF：异步执行一个AOF（AppendOnly File）文件重写操作。
* BGSAVE：在后台异步保存当前数据库的数据到磁盘。

* CLIENT KILL [ip:port] [ID client-id]：关闭客户端连接。
* CLIENT LIST：获取连接到服务器的客户端连接列表。
* CLIENT PAUSE timeout：在指定时间内终止运行来自客户端的命令。
* CLIENT SETNAME connection-name：设置当前连接的名称。
* CLIENT GETNAME：获取连接的名称。

* CLUSTER SLOTS：获取集群节点的映射数组。

* COMMAND：获取Redis命令详情数组。
* COMMAND COUNT：获取Redis命令总数。
* COMMAND GETKEYS：获取给定命令的所有键。
* COMMAND INFO command-name [command-name ...]：获取指定Redis命令描述的数组。

* TIME：返回当前服务器时间。

* CONFIG GET parameter：获取指定配置参数的值。
* CONFIG REWRITE：对启动Redis服务器时所指定的redis.conf配置文件进行改写。
* CONFIG SET parameter value：修改redis配置参数，无需重启。
* CONFIG RESETSTAT：重置INFO命令中的某些统计数据。

* DBSIZE：返回当前数据库的key的数量。

* DEBUG OBJECT key：获取key的调试信息。
* DEBUG SEGFAULT：让Redis服务崩溃。

* FLUSHALL：删除所有数据库的所有key。
* FLUSHDB：删除当前数据库的所有key。

* INFO [section]：获取Redis服务器的各种信息和统计数值。

* LASTSAVE：返回最近一次Redis成功将数据保存到磁盘上的时间，以UNIX时间戳格式表示。
* MONITOR：实时打印出Redis服务器接收到的命令，调试用。
* ROLE：返回主从实例所属的角色

* SAVE：异步保存数据到硬盘。
* SHUTDOWN [NOSAVE] [SAVE]：异步保存数据到硬盘，并关闭服务器。
* SLAVEOF host port：将当前服务器转变为指定服务器的从属服务器(slave server)。
* SLOWLOG subcommand [argument]：管理redis的慢日志。
* SYNC：用于复制功能(replication)的内部命令。