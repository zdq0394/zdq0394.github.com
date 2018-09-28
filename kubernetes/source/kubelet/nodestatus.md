# Kube Node Status
Kubelet的Run方法会运行一个独立的goroutine，每隔一段时间就运行一次`syncNodeStatus`。
## syncNodeStatus主要流程
* syncNodeStatus
    * registerWithAPIServer
        * initialNode
            * setNodeStatus
        * tryRegisterWithAPIServer：在apiServer中注册或者更新node的信息。
    * updateNodeStatus
        * tryUpdateNodeStatus
            * setNodeStatus
            * setLastObservedNodeAddresses
            * kl.volumeManager.MarkVolumesAsReportedInUse
