# Registry as a pull through cache

目前，不支持mirror私有的registry，只能mirror中央Hub。

Registry可以配置成一个pull through cache。在这种模式下，Registry可以对普通的docker pull请求作出响应，并把内容存储在本地。

第一次从本地镜像mirror拉取镜像时，会从公共的Docker镜像仓库拉取镜像并存储在本地，然后交给客户端。在随后的请求中，本地镜像mirror可以从本地获取镜像交给客户端。

如果一个pull带着一个tag，Registry mirror将到远端确认它是否拥有最新的版本。如果没有，它将重新拉取最新的镜像并缓存它。

过期的陈旧的数据可能会充斥cache。当作为pull through cache运行时，Registry将周期性的清楚旧的内容以节省磁盘空间。如果后续有请求已经删除的内容的请求，Registry将重新从远程拉取并在此缓存。

