# PG和PGP
## 定义
```text
PG = Placement Group
PGP = Placement Group for Placement purpose
pg_num = number of placement groups mapped to an OSD
When pg_num is increased for any pool, every PG of this pool splits into half, but they all remain mapped to their parent OSD.
Until this time, Ceph does not start rebalancing. Now, when you increase the pgp_num value for the same pool, PGs start to migrate from the parent to some other OSD, and cluster rebalancing starts. This is how PGP plays an important role.
```

## PG和PGP
增加pg number：
```sh
ceph osd pool set testpool pg_num 64
```
查看pg number：
```sh
ceph osd pool get testpool pg_num
```
增加PG会引起PG内的对象分裂，也就是在OSD上创建了新的PG目录，然后进行部分对象的move的操作。

增加pgp number：
```sh
ceph osd pool set testpool pgp_num 64
```
查看pgp number：
```sh
ceph osd pool get testpool pgp_num
```
调整PGP不会引起PG内的对象的分裂，但是会引起PG的分布的变动。
## 结论
* PG是指定存储池存储对象的目录有多少个，PGP是存储池PG的OSD分布组合个数。
* PG的增加会引起PG内的数据进行分裂，分裂到相同的OSD上新生成的PG当中。
* PGP的增加会引起部分PG的分布进行变化，但是不会引起 PG 内对象的变动。