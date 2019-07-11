# Registry的详细配置
Registry的配置基于**yaml**文件。
## 覆盖某个（些）配置项
从官方镜像启动一个Registry的过程中，可以通过两种方式指定配置参数：
* docker run -e参数
* 在Dockerfile中使用ENV指令

举个例子：

```
storage:
  filesystem:
    rootdirectory: /var/lib/registry
```
如果要重新这个变量，就设置环境变量：
```
REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY=/somewhere
```
环境变量**REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY**的值**/somewhere**会覆盖**/var/lib/registry**。

## 覆盖整个配置文件
可以通过如下方法来覆盖整个配置文件：

``` 
docker run -d -p 5000:5000 --restart=always --name registry \
             -v /path/to/custom/config.yml:/etc/docker/registry/config.yml \
             registry:2
```

## 配置项
### version
配置的版本字段。
### log
配置logging系统的行为。
```
log:
  accesslog:
    disabled: true
  level: debug
  formatter: text
  fields:
    service: registry
    environment: staging
  hooks:
    - type: mail
      levels:
        - panic
      options:
        smtp:
          addr: smtp.sendhost.com:25
          username: sendername
          password: password
          insecure: true
        from: name@sendhost.com
        to:
          - name@receivehost.com
```

## storage
配置存储后端。
**只能配置一个**。

## auth
```
auth:
  silly:
    realm: silly-realm
    service: silly-service
  token:
    realm: token-realm
    service: token-service
    issuer: registry-token-issuer
    rootcertbundle: /root/certs/bundle
  htpasswd:
    realm: basic-realm
    path: /path/to/htpasswd
```

auth部分可选的。auth有3个provider，**只能配置其中一个**。
* silly
* token
* htpasswd

## middleware
middleware部分是可选的。

## reporting
reporting部分是可选的，配置error和metrics的报表工具。

目前仅支持：
* Bugsnag
* New Relic

```
reporting:
  bugsnag:
    apikey: bugsnagapikey
    releasestage: bugsnagreleasestage
    endpoint: bugsnagendpoint
  newrelic:
    licensekey: newreliclicensekey
    name: newrelicname
    verbose: true
```

## http
http部分详细描述支持Registry的HTTP服务器的配置。
```
http:
  addr: localhost:5000
  net: tcp
  prefix: /my/nested/registry/
  host: https://myregistryaddress.org:5000
  secret: asecretforlocaldevelopment
  relativeurls: false
  tls:
    certificate: /path/to/x509/public
    key: /path/to/x509/private
    clientcas:
      - /path/to/ca.pem
      - /path/to/another/ca.pem
    letsencrypt:
      cachefile: /path/to/cache-file
      email: emailused@letsencrypt.com
  debug:
    addr: localhost:5001
  headers:
    X-Content-Type-Options: [nosniff]
  http2:
    disabled: false
```
## notifications
```
notifications:
  endpoints:
    - name: alistener
      disabled: false
      url: https://my.listener.com/event
      headers: <http.Header>
      timeout: 500
      threshold: 5
      backoff: 1000
      ignoredmediatypes:
        - application/octet-stream
```
配置一系列的服务用来接受notifications。
**endpoints**包含一系列命令的服务，这些服务接收event notification。 
## redis
```
redis:
  addr: localhost:6379
  password: asecret
  db: 0
  dialtimeout: 10ms
  readtimeout: 10ms
  writetimeout: 10ms
  pool:
    maxidle: 16
    maxactive: 64
    idletimeout: 300s
```
声明创建redis连接的参数。
Registry可以为多种应用使用Redis实例。目前，用来缓存不可变的blobs的信息。
应该为redis配置**allkeys-lru eviction policy**。

## health
```
health:
  storagedriver:
    enabled: true
    interval: 10s
    threshold: 3
  file:
    - file: /path/to/checked/file
      interval: 10s
  http:
    - uri: http://server.to.check/must/return/200
      headers:
        Authorization: [Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ==]
      statuscode: 200
      timeout: 3s
      interval: 10s
      threshold: 3
  tcp:
    - addr: redis-server.domain.com:6379
      timeout: 3s
      interval: 10s
      threshold: 3
```
health部分是可选的，包含了对下列组件的周期性检查（check）：
* storage driver’s backend storage
* local files 
* HTTP URIs
* TCP servers 

检查结果可以从debug HTTP服务器的端点/debug/health获取，如果debug HTTP服务器打开的话。

## proxy
```
proxy:
  remoteurl: https://registry-1.docker.io
  username: [username]
  password: [password]
```
proxy结构可以将registry配置为**Docker Hub**的一个mirror：pull-through cache。
不能推送镜像到pull-through cache。

## compatibility
```
compatibility:
  schema1:
    signingkeyfile: /etc/registry/key.json
```
compatibility结构用来配置旧的或者废弃的特性。 

## validation
```
validation:
  enabled: true
  manifests:
    urls:
      allow:
        - ^https?://([^/]+\.)*example\.com/
      deny:
        - ^https?://www\.example\.com/
```
* 如果allow没有设置，如果包含urls，则pushing manifest失败。
* 如果allow设置，只有urls和allow中的某个正则表达式匹配，并且
  * deny没有设置
  * deny设置，但时urls和任何一个正则表达式都部匹配。

