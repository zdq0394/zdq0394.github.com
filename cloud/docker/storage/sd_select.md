# Select a Storage Driver
理想情况下，不应该有数据写到容器的writable layer，应该把数据写到Docker Volumes。
然而，有些应用有把数据写到writable layer的需求，这就要用到storage driver。

Docker以插件的方式支持多种storage driver。
Storage Driver控制和管理宿主机上的镜像和容器。

## Supported storage drivers per Linux distribution
### Docker EE and CS-Engine
[Product compatibility matrix](https://success.docker.com/article/Compatibility_Matrix)
### Docker CE
* Ubuntu： aufs，devicemapper，overlay2（14.04.4及以后版本；16.04及以后版本），overlay，zfs，vfs
* Debian： aufs，devicemapper，overlay2（Debian Stretch），overlay，vfs
* Centos： devicemapper，vfs
* Fedora： devicemapper，overlay2（Fedora 16及以后版本，experimental），overlay（experimental），vfs

只要条件满足，overlay2就是首选的storage driver。

## Supported backing filesystems
对Docker来说，backing filesystem就是`/var/lib/docker`目录所在的文件系统。
有些storage driver需要特定的backing filesystem。
* overlay,overlay2：ext4, xfs
* aufs：ext4, xfs
* devicemapper：direct-lvm
* btrfs：btrfs
* zfs：zfs

## Suitability for your workload
* aufs，overlay，和overlay2都是在file level操作，而不是block level。对内存的使用效率高，但是对于write-heavy的应用，容器的writable layer增长过快。 
* Block-level的storage drivers，比如devicemapper，btrfs和zfs在write-heavy workloads方面表现比较好，当然最好还是使用docker volumes。
* 对于很多small writes的容器，或者容器的层数很多，overlay比overlay2表现要好。
* btrfs和zfs都需要大量内存。
* zfs更适合高密度负载的场景，比如PaaS。

## Stability
aufs、overlay和devicemapper稳定性更好。

