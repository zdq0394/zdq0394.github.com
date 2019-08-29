# Flanneld 源码分析
## 基本术语
* SubnetManager：一个node节点分配一个独立的subnet。SubnetManager的主要作用是监听flannel存储（etcd/kubeapi），发现node节点的Add/Delete/Update等事件，以备处理。
* Backend：Flannel Fabric的实现方式——UDP/Vxlan/HostGW等。不同的Backend对应的网络是不一样的。
* Network：由Backend组成的网络，每当Network的SubnetManager发现node节点的事件时，Network会进行一定的动作，比如增加routes/arp/fdb等。
* ExternalInterface：node节点上的Iface，提供物理链路。

## 主流程
所谓主流程就是main方法中的调用流程，包括一下几个大步骤：
1. 首先找出Node节点上的ExternalInterface。
2. 构建针对该Node节点的SubnetManager。
3. 构建BackendManager，BackendManager中包含以上两个属性。
4. 根据配置文件中的BackendType，比如vxlan，构建对应的Backend。
5. 由Backend生成一个网络
6. 上面生成的网络运行：处理收到SubnetManager收到的事件进行处理，构建Flannel Fabric。
```go
...

	// Work out which interface to use
	var extIface *backend.ExternalInterface
...

	sm, err := newSubnetManager()

...
    config, err := getConfig(ctx, sm)
    bm := backend.NewManager(ctx, sm, extIface)
    be, err := bm.GetBackend(config.BackendType)
    bn, err := be.RegisterNetwork(ctx, wg, config)
...

    go func() {
		bn.Run(ctx)
		wg.Done()
	}()

...
```
可以看出Flanneld的作用范围其实是构建了各个Node之间的Fabric通路。至于Node上各个Pod如何连接到Fabric上，则是CNI Plugin——flannel（这个plugin的名字也叫flannel）的作用范围了。

## Network的run流程
### run框架流程
1. 构建一个Event的buffered chan——events。
2. 以一个独立goroutine调用subnet的WatchLeases方法，subnet manager 发现（watch）的event注入到events channel。
3. 当前goroutine陷入循环，执行events channel中的事件。怎么处理呢？请看`nw.handleSubnetEvents(evtBatch)`。
大致流程代码如下：
```go
func (nw *network) Run(ctx context.Context) {
    ...
	events := make(chan []subnet.Event)


	go func() {
		subnet.WatchLeases(ctx, nw.subnetMgr, nw.SubnetLease, events)
	}()


	for {
		select {
		case evtBatch := <-events:
			nw.handleSubnetEvents(evtBatch)

		case <-ctx.Done():
			return
		}
	}
}
```
不同Backend的Network的`nw.handleSubnetEvents(evtBatch)`方法不一样。
## SubnetManager Watch流程
### Watch流程
上一节看到，Network的run流程中，通过一个独立goroutine调用subnet.WatchLeases(ctx, nw.subnetMgr, nw.SubnetLease, events)方法，获取subnetmanager中的events。

那具体是如何实现的呢？通过代码可以发现这是通过调用具体的subnetmanager的WatchLeases方法实现的。
```go
func WatchLeases(ctx context.Context, sm Manager, ownLease *Lease, receiver chan []Event) {
	lw := &leaseWatcher{
		ownLease: ownLease,
	}
	var cursor interface{}

	for {
		res, err := sm.WatchLeases(ctx, cursor)
		if err != nil {
			if err == context.Canceled || err == context.DeadlineExceeded {
				return
			}

			log.Errorf("Watch subnets: %v", err)
			time.Sleep(time.Second)
			continue
		}

		cursor = res.Cursor

		var batch []Event

		if len(res.Events) > 0 {
			batch = lw.update(res.Events)
		} else {
			batch = lw.reset(res.Snapshot)
		}

		if len(batch) > 0 {
			receiver <- batch
		}
	}
}
```

### Kube API的ListWatch机制
以KubeSubnetManager为例：
KubeSubnetManager本质上是一个对Kube API object Node的一个ListWatch控制器。KubeSubnetManager的run方法启动该控制器。
根据监控到的Node节点的状态变化，分别执行如下3个方法：
* AddFunc：ksm.handleAddLeaseEvent(subnet.EventAdded, obj)
* UpdateFunc：ksm.handleUpdateLeaseEvent
* DeleteFunc：ksm.handleAddLeaseEvent(subnet.EventRemoved, obj)

通过代码可以发现，这三个方法最终都会把一个Event事件放入subnetmanager的events chan中，这个chan的大小目前设置为5000。

```go
    indexer, controller := cache.NewIndexerInformer(
		&cache.ListWatch{
			ListFunc: func(options metav1.ListOptions) (runtime.Object, error) {
				return ksm.client.CoreV1().Nodes().List(options)
			},
			WatchFunc: func(options metav1.ListOptions) (watch.Interface, error) {
				return ksm.client.CoreV1().Nodes().Watch(options)
			},
		},
		&v1.Node{},
		resyncPeriod,
		cache.ResourceEventHandlerFuncs{
			AddFunc: func(obj interface{}) {
				ksm.handleAddLeaseEvent(subnet.EventAdded, obj)
			},
			UpdateFunc: ksm.handleUpdateLeaseEvent,
			DeleteFunc: func(obj interface{}) {
				node, isNode := obj.(*v1.Node)
				// We can get DeletedFinalStateUnknown instead of *api.Node here and we need to handle that correctly.
				if !isNode {
					deletedState, ok := obj.(cache.DeletedFinalStateUnknown)
					if !ok {
						glog.Infof("Error received unexpected object: %v", obj)
						return
					}
					node, ok = deletedState.Obj.(*v1.Node)
					if !ok {
						glog.Infof("Error deletedFinalStateUnknown contained non-Node object: %v", deletedState.Obj)
						return
					}
					obj = node
				}
				ksm.handleAddLeaseEvent(subnet.EventRemoved, obj)
			},
        },
```

而kubeSubnetManager的WatchLeases方法会将当前events chan中一个event封装为LeaseWatchResult返回给外界：
```go
func (ksm *kubeSubnetManager) WatchLeases(ctx context.Context, cursor interface{}) (subnet.LeaseWatchResult, error) {
	select {
	case event := <-ksm.events:
		return subnet.LeaseWatchResult{
			Events: []subnet.Event{event},
		}, nil
	case <-ctx.Done():
		return subnet.LeaseWatchResult{}, nil
	}
}
```

## 总结
* kubeSubnetManager通过ListWatch机制将Node的变成事件，保存到kubeSubnetManager的events chan中。
* kubeSubnetManager提供WatchLeases方法，将events chan中的一个event作为LeaseWatchResult返回给外界。
* 外界方法WatchLeases，循环调用subnetManager的WatchLeases方法，获取event事件，注入到方法提供的receiver chan中。
* Network中根据receiver chan中的事件进行处理，当然不同类型的Network实现方式不一样。









    
