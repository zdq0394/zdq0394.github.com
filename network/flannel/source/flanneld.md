# Flanneld 源码分析
## Flanneld概述
Flanneld进程以daemon运行在每个node节点上，负责该节点的网络（一个子网Subnet）通过节点上的网卡（External Interface）与其它节点node上的网络联通。

Node节点上的子网与其它节点的子网的联通方式有一下几种，每种称为一个Backend。
HostGW：Node节点处于一个二层网络，直接在二层联通。
VxLan：Node节点处于一个三层网络，二层不直接相通，那么通过VxLan技术在三层网络上面Overlay一个二层网络，使得各个Host在二层相通。

每个Flanneld管理一个网络（子网）`network`，这个`network`借助`subnet manager`监听集群中各个node的变化，根据`node`的变化然后借助具体的`backend`动作实现网络状态的更新。具体的网络动作包括：路由表、ARP表以及FDB表的增加/删除/更新等。不同的backend实现不太一样。HostGW Backend只需要更新路由表即可；而VxLAN则要同时更新三个表。

![](flanneld_daemon.png)

## 基本术语
* Network：一个节点上的Flanneld管理的一个子网就是一个网络。网络通过Backend实现联通性，通过SubnetManager发现node节点的事件，Network根据事件更新网络状态。
* SubnetManager：一个node节点分配一个独立的subnet。SubnetManager监听flannel存储（etcd/kubeapi），发现node的Add/Delete/Update等事件。其实就是通知当前网络：一个新的子网加入/离开了，需要配置合适的规则，将当前网络与目标网络联通/断开。
* Backend：Flannel底层Fabric的实现方式——Vxlan/HostGW等。
* ExternalInterface：node节点上的Iface，提供物理链路。

## 主流程
这里说的主流程就是main方法中的调用流程，包括一下几个大步骤：
1. 首先找出Node节点上的`ExternalInterface`。
2. 构建针对该Node节点的`SubnetManager`。
3. 构建`BackendManager`，`BackendManager`中包含以上两个属性。
4. 根据配置文件中的`BackendType`，比如vxlan，构建对应的`Backend`。
5. 由`Backend`生成一个`network`。
6. 网络运行daemon：处理SubnetManager监测到的事件，更新网络状态。
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
可以看出Flanneld的作用其实是构建了各个Node的网络（Subnet）之间的联通性。至于Node上各个Pod如何连接到Node子网上，则是CNI Plugin——flannel（这个plugin的名字也叫flannel）的作用范围。

## Network的run流程
### run框架流程
1. 构建一个Event的buffered chan——events。
2. 以一个独立goroutine调用SubnetManager的WatchLeases方法，将SubnetManager发现（watch）的event注入到events channel。
3. 当前goroutine陷入循环，处理events channel中的事件。
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
网络如何处理events事件呢？不同Backend的Network的`nw.handleSubnetEvents(evtBatch)`方法不一样。

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

而SubnetManager的WatchLeases方法会将当前events chan中一个event封装为LeaseWatchResult返回给外界，以kubeSubnetManager为例：
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
kubSubnetManager结构体中包含一个Event类型的chan——events。
```go
type kubeSubnetManager struct {
	annotations    annotations
	client         clientset.Interface
	nodeName       string
	nodeStore      listers.NodeLister
	nodeController cache.Controller
	subnetConf     *subnet.Config
	events         chan subnet.Event
}
```
那接下来的问题是events这个chan的事件哪里来的？答案是通过Kubernetes client-go的ListWatch机制检测发现，然后加入到chan中的。
### Kube API的ListWatch机制
KubeSubnetManager本质上是一个对Kubeapi object Node的一个ListWatch控制器。KubeSubnetManager的run方法启动该控制器。

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
## Flanneld流程总结
* kubeSubnetManager通过ListWatch机制检测Node的事，保存到kubeSubnetManager的events chan中。
* kubeSubnetManager提供WatchLeases方法，将events chan中的一个event作为LeaseWatchResult返回给外界。
* Network调用WatchLeases，循环调用subnetManager的WatchLeases方法，采集event事件，注入到方法提供的receiver chan中。
* Network中根据receiver chan中的事件进行处理，不同Backend的Network实现方式不一样的。HostGW Backend只需要更新路由表；而VxLAN则要同时更新ARP表、FDB表和路由表。

## SubnetFile
Flanneld默认将把Subnet信息写入到SubnetFile中`/run/flannel/subnet.env`。

内容大概如下：
```
FLANNEL_NETWORK=192.169.0.0/16
FLANNEL_SUBNET=192.169.1.1/24
FLANNEL_MTU=1450
FLANNEL_IPMASQ=false
```

Flannel的CNI插件将使用到该文件。







    
