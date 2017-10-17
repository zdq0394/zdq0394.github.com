# Work with notifications
对于Registry中产生的事件（events），Registry支持发送webhook通知。
每当有manifest上传（push）和拉取（pull）或者layer上传（push）和拉取（pulls）等类似的事件产生时，就会有通知发出。
这些动作会被序列化为事件（events），然后事件会以**队列**形式存放在一个registry内部的广播系统中：该系统可以按顺序将事件排队并且将事件分发到一个个的endpoints中。

![](pics/registry_notifications.png)

## Endpoints
通知以HTTP请求的形式发往endpoints。
在registry实例中，对每个配置的endpoint都有**独立的队列（queue）**、重试方式和http目标。
当一个动作发生后，动作会被转换为一个事件，这个事件会发送到一个内存队列中。
当事件到达队列终点时，就会触发一个发往endpoint的http请求，直到请求成功。
事件被串行发到各个endpoints，但是无法保证到达顺序。

## Configuration
为了使registry可以发通知到某个endpoint，需要添加配置：

```yaml
notifications:
    endpoints:
      - name: alistener
        url: https://mylistener.example.com/event
        headers:
          Authorization: [Bearer <your token, if needed>]
        timeout: 500ms
        threshold: 5
        backoff: 1s
```

上面的例子配置了一个端点：https://mylistener.example.com/event。
并且提供了认证信息：Authorization: Bearer <your token, if needed>。请求将在500毫秒之后超时。如果相继发生5次失败，registry将退避1秒钟之后再重试。

## Events

Events拥有定义良好的JSON结构，并作为通知的http请求体。也可以使用envelope作为发送通知的请求体，envelope可以包含多个事件。每个拥有一个唯一的ID，可以用来标识一个请求，如果需要的话。

## Envelope

Envelope包括一个或者多个事件，具有如下结构：
```
{
         "id": "asdf-asdf-asdf-asdf-0",
         "timestamp": "2006-01-02T15:04:05Z",
         "action": "push",
         "target": {
            "mediaType": "application/vnd.docker.distribution.manifest.v1+json",
            "length": 1,
            "digest": "sha256:fea8895f450959fa676bcc1df0611ea93823a735a01205fd8622846041d0c7cf",
            "repository": "library/test",
            "url": "http://example.com/v2/library/test/manifests/sha256:c3b3692957d439ac1928219a83fac91e7bf96c153725526874673ae1f2023f8d5"
         },
         "request": {
            "id": "asdfasdf",
            "addr": "client.local",
            "host": "registrycluster.local",
            "method": "PUT",
            "useragent": "test/0.1"
         },
         "actor": {
            "name": "test-actor"
         },
         "source": {
            "addr": "hostname.local:port"
         }
      }
```

``` yaml
{
	"events": [ ... ],
}
```
同一个envelope中的事件或许**没有**任何关系。

## Responses
Registry会fairly接受endpoints返回的response codes。 如果一个endpoints返回**2xx**或者**3xx**，Registry会认为该消息已成功发送并将其丢弃。

## Monitoring
Endpoints的状态会通过HTTP接口debug/vars汇报：http://localhost:5001/debug/vars。

## Considerations
当前，queues仍然是inmemory的，所以endpoints应该相当的可靠。Registry提供best-effort的努力将消息发出去，但是一旦registry宕机，消息就丢掉了。如果一个endpoints宕机了，必需非常小心确保在endpoint恢复之前，registry不能宕机，否则所有的消息都会丢弃。
