# Jenkins性能提升
## Jenkins Master配置
### 插件数量
不要添加过多的插件，一定要充分评估后再安装。
插件会导致构建（因为hook）和UI（插件会添加界面元素到UI）加载时的性能问题。

### JOB数量
当job数量达到1000+时，Jenkins（UI）会变慢。

通过手工静态分区的方式将job分散到多个Master上可以有效的提升性能：比如一台Master用于构建，一台Master用于测试。
Master功能分离可以有效简化Jenkins配置并减少插件的数量。

保持激活状态的job处在合理的数量，将无用的job删除。

利用Git和Gerrit Trigger插件配置一组job来支持多分支的情况。

### 禁止在Master上运行job
Master上不应该运行job，或者只能运行对Jenkins管理至关重要的内部轻量级任务（Jenkins备份、Job清理），绝对不能运行业务Job。

* Job必须通过Restrict where this project can be run指定Slave，最好是采用**label**来指定一类Slave
* 禁用Master作为slave，可以断开连接或者在系统设置中将**执行者数量**设置为0。

### 减少在Master上轮询SCM
针对Git或者Perforce的SCM轮询需要为每个Job的每次轮询运行CLI程序。
如果想要可靠的轮询，则应该运行在Master上，不建议在Slave上轮询，因为Slave是不可靠的。

* 建议使用push hooks代替轮询，Git可以在大多情况下使用Gerrit Trigger的"Ref update"事件来代替SCM轮询。
* 针对Perforce，可以将轮询时间间隔设置的长一些，使用“H”或者“@hourly”来配置计划任务。

### Build延迟加载
当JVM的minimum和maximum heap sizes不同时，WeakReferences（延迟加载时使用）会在JVM尝试扩展heap之前进行垃圾回收。
这会导致Build在重新加载时产生额外的加载，某些情况下还会导致Build记录丢失。

服务器的JVM配置必须保证**minimum和maximum值相同**。

### 权限控制
认证用户应该允许拥有除系统管理员以外的所有权限。

### 磁盘IO性能
为job配置（启动时）和Build记录（延迟加载）使用更快的磁盘。
Master采用SSD会很有帮助，分离配置、Build记录、构件存储。

### 使用外部API/UI作为Jenkins前端
Jenkins并不擅长UI性能，UI插件会导致UI性能变的更糟。
外部的UI面板或前端系统可以作为替代方案。

### HTTP缓存
使用快速的HTTP代理以缓存静态数据可以帮助提升性能。

使用Nginx除了代理端口转发之外，还可以缓存静态文件，比如图片、CSS等，即动静分离，是Web应用的常见方法。

### Servlet容器
Jetty is OK

## Jenkins Slave配置
### Slave数量
Jenkins开发团队有一个目标叫做“X1K initiative”，即保证Jenkins Master能支持所有Slave共1000个执行器的平滑运行。
有证据显示：当slave过百时，Jenkins会出现Slave连接丢失的情况。
### 单个Slave的执行器数量
超过Slave容量的情况下，增加执行器数量会因为崩溃、IO阻塞、RAM交换导致整体的吞吐量下降。
合理配置RAM, CPU cores and build 类型。
* RAM配置：Slave的maximum memory setting需要能够支持最大的Build。
* CPU：应该配置到足够使用，不会出现100%。
* 考虑IO时，IO会释放一些CPU时间，针对单线程的Build，**每个CPU核心配置应少于1个执行器**。
* 考虑到IOPS限制，为了避免磁盘IO成为瓶颈，一般情况下，如果15分钟内，平均负载超过了CPU核心数量，则执行器数量应该降低。建议，每个Slave配置1个执行器以便实现隔离。

## Job Design
### 清理Workspace
在Build之前删除Job的Workspace，以便获取干净的Build，或者在Build之后删除Job的Workspace，以便节约磁盘空间。
这会导致重新签出代码，对Maven下载依赖而言可能时间更长，最终的Build耗时可能会翻倍。

应该在构建系统中明确，在构建脚本中明确使用可靠的目标"clean"，禁止在临时构建目录以外创建文件。
永远不要修改版本控制下的文件。
对于发布构建而言，如果构建正确性优于构建速度，可以经常定期的清理workspace。


### 构件指纹
大型的指纹数据库可能会导致Jenkins Master性能下降。
Copy Artifact plugin 总是会检查指纹。
Maven构建会无条件地记录文件的指纹。

因此，**阻止code review(Gerrit) build在Maven2/3构建时记录指纹**，也许可以禁用Maven存档构件。

对于自由风格的Job也同样适用。

### 构建后操作
限制构建后步骤，它会引发并发构建变成串行。

### Maven Job vs Freestyle jobs
使用**自由风格的Job**，Maven Job尤其慢，并且有一些Bug。

Jenkins核心贡献者都认为Maven job类型并不好。

### 大型构建日志
构建历史日志会加载到Jenkins Master的内存中，如果构建日志过大，由此会引发内存溢出错误。
使用Log File Size Checker plugin以便在控制台输出log超出限制时让Job失败。

### Sonar分析
在每次Build是使用Sonar分析会导致2-3倍的耗时。
Sonar是一个监控和代码检查工具，不是守门人，在晚上执行Sonar，而不是在每次Build。

### Reference repository for Git SCM
本地文件系统的Git仓库可以当做引用，只下载更新的代码，其他代码都是硬链接。

## Multi Master
目前还没有多Master Jenkins 集群，在可预见的未来也不会有。

在不定制Jenkins的情况下，唯一能够实现负载在Master之间共享的，只能是搭建多个master，分别支持不同的Job。