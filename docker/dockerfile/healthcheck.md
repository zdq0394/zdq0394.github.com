# HEALTHCHECK
**HEALTHCHECK**指令有两种形式：
* `HEALTHCHECK [OPTIONS] CMD command` (check container health by running a command inside the container)
* `HEALTHCHECK NONE` (disable any healthcheck inherited from the base image)

**HEALTHCHECK**指令通知Docker如何测试一个容器是否还在运行，比如一个web container，web服务器陷入了无限循环不能接受新的请求。

如果一个容器配置了healthcheck，在它正常的状态之外，会多出一个health status。

HEALTH STATUS：
* starting：初始化状态
* healthy：检查通过
* unhealthy：连续失败一定的次数（retries）

可以出现在CMD之前的OPTIONS包括：
* --interval=DURATION (default 30s)
* --timeout=DURATION (default 30s)
* --start-period=DURATION (default 0s)
* --retries=N (default 3)

第一次运行是在contaier is started之后的**interval**秒后。然后每次间隔**interval**秒，直到成功或者超过重试次数。

如果一次check时间超过**timeout**，则认为本次check失败。

如果连续失败**retries**，则容器状态为unhealthy。

**start-period**提供了容器启动的时间。
这个时间段之内的失败不会记入失败次数。
如果这个时间段内测试成功了，则认为容器是"started"，那么随后进入测试阶段，如果测试失败，则会计入失败次数。

HEALTHCHECK指令只能出现一次，如果出现多次，只有最后一次生效。
