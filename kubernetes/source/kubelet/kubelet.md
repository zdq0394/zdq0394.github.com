# Kubelet
## Kubelet核心流程
kubelet的Run方法中执行了kubelet的主要流程：
* 开启logServer
* 开启cloudResourceSyncManager
* 初始化内部模块initializeModules
    * 注册prometheus metrics
    * setupDataDirs
        * root directory
        * pods directory
        * plugins directory
    * ContainerLogsDir
    * 开启imageManager
    * 开启serverCertificateManager
    * 开启oomWatcher
    * 开启resourceAnalyzer
* 开启volumeManager
* 运行syncNodeStatus
* 运行nodeLeaseController
* 运行updateRuntimeUp
* 运行syncNetworkUtil
* 运行podKiller
* 开启statusManager
* 开启probeManager
* 开启runtimeClassManager
* 开启pleg
* 开启syncLoop
