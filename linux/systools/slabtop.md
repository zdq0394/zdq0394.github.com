# slabtopq
## 介绍
slabtop展示内核实时的slab cache信息。
## 使用方式
slabtop -d
```sh
slabtop

 Active / Total Objects (% used)    : 3338395 / 3804494 (87.7%)
 Active / Total Slabs (% used)      : 98004 / 98004 (100.0%)
 Active / Total Caches (% used)     : 77 / 113 (68.1%)
 Active / Total Size (% used)       : 686579.71K / 747197.20K (91.9%)
 Minimum / Average / Maximum Object : 0.01K / 0.20K / 15.88K

  OBJS ACTIVE  USE OBJ SIZE  SLABS OBJ/SLAB CACHE SIZE NAME                   
2492451 2090208  83%    0.10K  63909	   39    255636K buffer_head
425411 425411 100%    0.57K  15194	 28    243104K radix_tree_node
109284  93563  85%    0.19K   2602	 42     20816K dentry
 61440  53404  86%    0.06K    960	 64	 3840K kmalloc-64
 57035  55565  97%    0.05K    671	 85	 2684K shared_policy_node
 56100  48070  85%    0.04K    550	102	 2200K ext4_extent_status
 51660  51660 100%    0.11K   1435	 36	 5740K sysfs_dir_cache
 50787  43356  85%    1.02K   1641	 31     52512K ext4_inode_cache
 38106  38106 100%    0.05K    522	 73	 2088K uhci_urb_priv
 31920  31692  99%    0.07K    570	 56	 2280K Acpi-ParseExt
 28032  27776  99%    0.03K    219	128	  876K jbd2_revoke_record_s
 24995  23751  95%    0.58K    499	 55     15968K inode_cache
 23552  23552 100%    0.01K     46	512	  184K kmalloc-8
 23232  22976  98%    0.06K    363	 64	 1452K ext4_free_data
 22596  21101  93%    0.19K    538	 42	 4304K kmalloc-192
 21941  19370  88%    0.21K    593	 37	 4744K vm_area_struct
 19606  17687  90%    0.64K    401	 49     12832K proc_inode_cache
 18240  16068  88%    0.12K    570	 32	 2280K kmalloc-128
 16256  13650  83%    0.06K    254	 64	 1016K anon_vma
 16128  14277  88%    0.02K     63	256	  252K kmalloc-16
 15792  14659  92%    0.09K    376	 42	 1504K kmalloc-96
 15402  14804  96%    0.08K    302	 51	 1208K selinux_inode_security
 13312  13200  99%    0.03K    104	128	  416K kmalloc-32
 12832  10100  78%    0.25K    401	 32	 3208K kmalloc-256
 12138  11970  98%    0.62K    238	 51	 7616K sock_inode_cache
 11883  11526  96%    0.31K    233	 51	 3728K nf_conntrack_ffffffff81a25e00
 10728  10728 100%    0.11K    298	 36	 1192K jbd2_journal_head
  7744   7344  94%    0.50K    242	 32	 3872K kmalloc-512
  7684   7684 100%    0.12K    226	 34	  904K fsnotify_event
  7200   6834  94%    1.00K    225	 32	 7200K kmalloc-1024
  7176   6722  93%    0.81K    184	 39	 5888K task_xstate
  7038   7038 100%    0.08K    138	 51	  552K ext4_io_end
  6896   6340  91%    0.38K    168	 42	 2688K blkdev_requests
  6552   6228  95%    0.44K    182	 36	 2912K scsi_cmd_cache
  5440   5440 100%    0.02K     32	170	  128K fsnotify_event_holder

```