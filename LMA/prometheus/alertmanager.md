# Alertmanager
## 概述
Alerting with Prometheus包括两部分。
* Prometheus中配置告警规则，发送alert到Alertmanager。
* Alertmanager管理收到的告警，并对外发通知。

建立alerting和notifications的主要步骤如下：
1. 安装和配置Alertmanager。
2. 配置Prometheus使用Alertmanager作为告警平台。
3. 在Prometheus中配置alerting rules。