# istio
An open platform to connect, secure, control and observe services.

`istio`是一个开放平台，对微服务（services）提供四大功能：
* connect：连接
* secure：加固
* control：控制
* observe：观察
## Connect
[规则](rules.md)
## Secure

## Control
Mixer is the Istio component responsible for providing policy controls and telemetry collection.

The Envoy sidecar logically calls Mixer before each request to perform precondition checks, and after each request to report telemetry. 

Mixer is in essence an attribute processing machine.
## Observe
Mixer is the Istio component responsible for providing policy controls and telemetry collection.