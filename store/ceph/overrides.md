# ceph集群状态行为干预
* ceph osd set [flag]
* ceph osd unset [flag]

## flag
* noin： Prevents OSDs from being treated as in the cluster.
* noout： Prevents OSDs from being treated as out of the cluster.
* noup： Prevents OSDs from being treated as up and running.
* nodown： Prevents OSDs from being treated as down.
* full： Makes a cluster appear to have reached its full_ratio, and thereby prevents write operations.
* pause： Ceph will stop processing read and write operations, but will not affect OSD in, out, up or down statuses.
* nobackfil： Ceph will prevent new backfill operations.
* norebalance： Ceph will prevent new rebalancing operations.
* norecover： Ceph will prevent new recovery operations.
* noscrub： Ceph will prevent new scrubbing operations.
* nodeep-scrub： Ceph will prevent new deep scrubbing operations.* 
* notieragent： Ceph will disable the process that is looking for cold/dirty objects to flush and evict.
