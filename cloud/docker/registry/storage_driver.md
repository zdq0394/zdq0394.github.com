# Docker Registry Storage Driver
## Provided drviers

* inmemory: 使用inmemory map作为存储
* filesystem: 使用本地文件系统的一个目录树
* s3: 使用Amazon S3桶
* azure: 使用Microsoft Azure Blob Storage
* swift: 使用Openstack Swift
* oss: 使用阿里云OSS
* gcs: 使用Google Cloud Storage bucket

## filesystem

* rootdirectory: 默认是/var/lib/registry
* maxthreads: 阻塞式文件操作的最大值：默认100，不得少于25