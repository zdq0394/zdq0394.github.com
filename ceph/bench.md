# Ceph Rados Bench测试
命令：
rados -p <POOL> bench <SECONDS> write|seq|rand [-t concurrent_operations] [--no-cleanup] [--run-name run_name]
* default is 16 concurrent IOs and 4 MB ops
* default is to clean up after write benchmark
* default run-name is 'benchmark_last_metadata'

举例：
rados -p testpool bench 20 write --no-cleanup