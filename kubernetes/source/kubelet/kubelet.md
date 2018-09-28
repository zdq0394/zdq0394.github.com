# Kubelet
## Kubelet核心流程
* 开启，表示独立的自治组件，由单独的goroutine运行。
* 运行，由wait.util框架周期性执行的功能块。
* 生成，生成对象或者对象管理器，提供管理方法（工具方法）由外界调用执行。
kubelet的Run方法中执行了kubelet的主要流程：
* 开启logServer
* 开启cloudResourceSyncManager
* 初始化内部模块initializeModules
    * 注册prometheus metrics
    * 生成setupDataDirs
        * root directory
        * pods directory
        * plugins directory
    * 生成ContainerLogsDir
    * 开启imageManager：此处开启的是Image GC Manager。
    * 开启serverCertificateManager
    * 开启oomWatcher：OOMWatcher从cAdvisor获取`oom`事件，然后将事件Post到kubelet中。
    * 开启resourceAnalyzer：提供node资源的消费汇总数据。
        * fsResourceAnalyzer
        * summaryProvider
* 开启volumeManager
* 运行syncNodeStatus
    * registerWithAPIServer
    * updateNodeStatus
* 运行nodeLeaseController
* 运行updateRuntimeUp
    * 如果runtime没有up，则返回。
    * 如果runtime已经up，则执行initializeRuntimeDependentModules
        * 开启cadvisor
        * 开启containerManager
        * 开启evictionManager
        * 开启containerLogManager
        * pluginWatcher添加Handler，并开启pluginWatcher
            * CSIPlugin
            * DevicePlugin
* 运行syncNetworkUtil：确保network utility安装到host上
    * KUBE-MARK-DROP
    * KUBE-MARK-MASQ
* 运行podKiller：通过一个chan获取不需要的pod，并删除之。
* 开启statusManager：同步pod status到apiServer中。
* 开启probeManager
* 开启runtimeClassManager：缓存RuntimeClass API Objects，供Kubelet访问。
* 开启pleg：Pod Lifecycle Event Generator。
* 开启syncLoop：程序的主要循环，监视三个channel（file、apiServer和http）的变化，并同步running state和desired state。
