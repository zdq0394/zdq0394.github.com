# docker使用https访问harbor
## 忽略https
一般情况下，我们使用harbor时，总是通过在/etc/docker/daemon.json中配置insecure-registries来忽略https。
配置方式如下：
```json
{
  "registry-mirrors": ["https://harbor.domain.io"],
  "insecure-registries": ["harbor.domain.io"]
}
```

## 使用https
如果要使用https，需要做如下配置(假设要访问的harbor地址：harbor.domain.io)：
`将harbor的证书ca.crt拷贝到/etc/docker/certs.d/harbor.domain.io/下，一般命名为ca.crt`



