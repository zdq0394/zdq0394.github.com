# Alertmanager
## 概述
Alerting with Prometheus包括两部分。
* Prometheus中配置告警规则，发送alert到Alertmanager。
* Alertmanager管理收到的告警，并对外发通知。

建立alerting和notifications的主要步骤如下：
1. 安装和配置Alertmanager。
2. 配置Prometheus使用Alertmanager作为告警平台。
3. 在Prometheus中配置alerting rules。

## Alertmanager机制简介
Alertmanager处理由类似Prometheus服务器等客户端发来的告警，之后需要去重、分组，并将它们通过路由发送到正确的接收器：比如电子邮件、Slack等。
Alertmanager还支持**沉默**和**告警抑制**的机制。

### 分组
当出现问题时，Alertmanager会收到一个单一的通知。
而当系统宕机时，很有可能成百上千的告警会同时生成。
Grouping机制在较大的中断中特别有用。

比如，当数十或数百个服务的实例在运行时，网络发生割裂，有可能服务实例的一半不可达数据库。
在告警规则中配置为每一个服务实例都发送告警的话，那么结果就是数百个告警被发送至Alertmanager。

但是作为用户只想看到单一的报警页面，同时仍然能够清楚的看到哪些实例受到影响，因此，通过配置Alertmanager将告警分组打包，并发送一个相对看起来紧凑的通知。

**分组**、**timing for the grouped notifications**，以及**接收通知的receiver**是在配置文件中通过**路由树**配置的。

### 抑制
抑制是停止发送某些告警的通知，当特定的其他告警正在发生时。

例如，当**整个集群不可达**的告警被触发时，可以配置Alertmanager忽略由该告警触发而产生的所有其他告警，这可以防止通知数百或数千与此问题不相关的其他告警。

抑制机制可以通过Alertmanager的配置文件来配置。

### 静默
静默是一种简单的特定时间静音提醒的机制。
一种静默是通过**匹配器**来配置，就像路由树一样。
传入的告警会匹配RE，如果匹配，将不会为此告警发送通知。

静默机制可以通过Alertmanager的Web页面进行配置。
