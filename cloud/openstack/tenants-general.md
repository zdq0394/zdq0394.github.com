# OpenStack多租户共享和隔离
OpenStack私有云和专有云是单租户模式的，因为其基础设施是由一个租户专享的；OpenStack公有云或者社区云是多租户模式，因为其基础设施是由多个租户共享的。

**多租户隔离**：某些租户往往要求在计算、网络和存储等方面的物理或者逻辑隔离性。OpenStack在这些方面分别有不同的技术来实现所需的隔离性。

## 计算的隔离
有些对安全性和性能要求高的用户，往往会要求将它的虚机部署在指定的专有的服务器上。

OpenStack Nova通过**Host aggregate**技术来支持这种需求的实现。

Nova的Scheduler.Filters提供了**AggregateMultiTenancyIsolation**。可以实现指定tenant的虚拟机只能创建到指定的Host Aggregate中。

``` text
If a host is in an aggregate that has the metadata key "filter_tenant_id" it can only create instances from that tenant(s).
A host can be in different aggregates.
If a host doesn't belong to an aggregate with the metadata key "filter_tenant_id" it can create instances from all tenants.
```

1. 创建一个Host Aggregate，为该Host Aggregate添加metadata: **filter_tenant_id=<My-Tenant-ID>
2. 将一些计算节点加入该Host Aggregate。这样创建虚拟机时，只有My-Tenant-ID的虚拟机才可以创建到这些计算节点上

## Cinder的物理隔离

Cinder 支持租户在指定的 backend 上创建卷 volume。通过VolumeType实现。

## Neutron的逻辑隔离
OpenStack私有云使用的网络设备往往包括ToR和核心交换机，路由器和防火墙等。这些设备价格昂贵，因此往往采取**逻辑隔离**的方式来保证安全性。Amazon Virtual Private Cloud （Amazon VPC）也是类似的方式，它允许用户在Amazon AWS云中预配置出一个采用逻辑隔离的部分，让您在自己定义的虚拟网络中启动 AWS 资源。

这部分的内容包括以下几种：
* Linux 网桥中 VLAN 模式租户隔离 （参考链接：Linux bridge + VLAN）
* Open vSwitch VLAN 模式租户隔离 （参考链接：Open vSwitch + VLAN）
* Open vSwitch VxLAN 模式租户隔离 （参考链接：Open vSwitch + VxLAN/GRE）
* Open vSwitch GRE 模式租户隔离  （参考链接：Open vSwitch + VxLAN/GRE）

## Glance和Swift多租户逻辑隔离
默认情况下是单租户模式，使用单个Swift用户和单个Container保存所有用户的镜像文件。

用户的虚机镜像文件通过Glance服务保存在Swift中。默认情况下，Glance使用一个统一的Swift用户名和密码在一个Swift存储中保存所有用户的镜像文件，这种模式被称为单租户Swift（Single Tenant Swift），它使用一个Swift账号保存所有用户的镜像在一个Swift容器（container）中。

1. 单租户多container：使用单个swift用户多个container

Glance配置参数

``` text
swift_store_multi_tenant=False # #默认是 false，因为该支持基于单租户模式
swift_store_multiple_containers_seed = <1 到 32 之间的整数> #默认为 0，表示使用单租户模式来保存所有用户的镜像文件。当设置为 1 到 32 之间的整数时，将会使用单租户 Swift 但是多个containers 来保存镜像，而 container 名称则取决于镜像的 UUID 字符串中的指定长度的子串。比如设置其值为 3，而且 swift_store_container = ‘glance’，那么UUID 为 ‘fdae39a1-bac5-4238-aba4-69bcc726e848’ 的镜像将被保存在 ‘glance_fda’ container 中。可见，这种模式中，所有用户的镜像将会被分散地保存到多个 container 中。
```

2. 多租户模式：使用多个swift用户

Glance配置参数

``` text
swift_store_multi_tenant = true #设置为 true，使能多租户模式，使得每个租户的镜像被保存在该租户对应的 swift 账号中 
swift_store_admin_tenants = 《tenant_id>:<username> <tenant_name>:<username> *:<username》 # openstack租户：swift账号
```

## Ceph的隔离

1. 使用Pool做逻辑隔离: 在使用默认的 CRUSH rules 的情况下，一个 Pool 所使用的 OSD 可能分布在不同的存储节点上。这时候，租户–pool–osd其实是逻辑隔离关系。
2. 定制CRUSH Rules对Pool做物理隔离: Ceph CRUSH Rules 会对数据如何存放在OSD上有直接的影响。因此，定义合适的Rules,可以使得一个Pool的OSD分布在指定的存储节点上。