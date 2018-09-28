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
    * 开启imageGCManager
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
