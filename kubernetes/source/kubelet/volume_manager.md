# Volume Manager
## Volume Manager
Volume Manager是Kubelet中的一个重要后台组件。
Volume Manager运行着一系列的异步后台goroutine，根据调度到所在node节点的pods及pods对volume的引用来attach/detach/mount/umount对应的卷。

后台异步goroutine主要包括`desiredStateOfWorldPopulator`和`reconciler`。
```go
func (vm *volumeManager) Run(sourcesReady config.SourcesReady, stopCh <-chan struct{}) {
	defer runtime.HandleCrash()

	go vm.desiredStateOfWorldPopulator.Run(sourcesReady, stopCh)
	glog.V(2).Infof("The desired_state_of_world populator starts")

	glog.Infof("Starting Kubelet Volume Manager")
	go vm.reconciler.Run(stopCh)

	metrics.Register(vm.actualStateOfWorld, vm.desiredStateOfWorld, vm.volumePluginMgr)

	<-stopCh
	glog.Infof("Shutting down Kubelet Volume Manager")
}
```

## 缓存
kubelet管理volume的方式基于两个状态：
* DesiredStateOfWorld：预期中的pod对volume的使用情况，简称预期状态。当pod.yaml定制好volume，并提交成功，预期状态就已经确定。
* ActualStateOfWorld：实际中的pod对voluem的使用情况，简称实际状态。实际状态是kubelet的后台线程监控发现的结果。
### DesiredStateOfWorld

### ActualStateOfWorld

### DesiredStateOfWorldPopulator
Kubelet从apiServer获取pods信息，然后同步到pod manager中。
DesiredStateOfWorldPopulator会根据pod manager中pods及其引用的volume信息来更新DesiredStateOfWorld。
### Reconciler
预期状态和实际状态的协调者。
它负责将实际状态调整到预期状态。
