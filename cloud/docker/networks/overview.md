# Docker container networking
## Default Networks
当安装好Docker之后，Docker自动创建好三个网络：
```sh
# docker network ls
NETWORK ID          NAME                DRIVER              SCOPE
7d1db683c070        bridge              bridge              local
8acd9fc92ff3        host                host                local
557349f4e13c        none                null                local
```
这三个网络是Docker内置的。
当运行一个容器的时候，可以使用`--network`指定容器要连接的网络。

1. 网络的名字是`bridge`，顾名思义，这是一个使用`网桥驱动`的网络。宿主机上网桥的名字默认是`docker0`。
默认情况下，即在创建容器时，不加`--network`，容器默认连接到网络`bridge`，也就是`docker0`上。
2. `none`网络将把容器加入到一个container-specific的网络stack中。容器没有network interface。
3. `host`网络将把容器加入到宿主机的网络栈中。如此，容器和宿主机在网络层面没有隔离。

The none and host networks are not directly configurable in Docker. However, you can configure the default bridge network, as well as your own user-defined bridge networks.

### The default bridge network
默认，所有的Docker宿主机都有`bridge`网络。通过`docker inspect bridge`命令查看网络信息：
```
# docker inspect bridge
[
    {
        "Name": "bridge",
        "Id": "7d1db683c0704cfbb0be3fbf5c636ab63fbc2eee3a5ca58aa3ba8d9a67607808",
        "Created": "2017-12-15T21:29:20.582306587+08:00",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": null,
            "Config": [
                {
                    "Subnet": "172.17.0.0/16"
                }
            ]
        },
        "Internal": false,
        "Attachable": false,
        "Ingress": false,
        "ConfigFrom": {
            "Network": ""
        },
        "ConfigOnly": false,
        "Containers": {},
        "Options": {
            "com.docker.network.bridge.default_bridge": "true",
            "com.docker.network.bridge.enable_icc": "true",
            "com.docker.network.bridge.enable_ip_masquerade": "true",
            "com.docker.network.bridge.host_binding_ipv4": "0.0.0.0",
            "com.docker.network.bridge.name": "docker0",
            "com.docker.network.driver.mtu": "1500"
        },
        "Labels": {}
    }
]
```
可以看出该网络的`"Driver": "bridge"`；宿主机上的网桥名字：`"com.docker.network.bridge.name": "docker0"`；网络地址范围： `"Subnet": "172.17.0.0/16"`。

关于bridge网络，可以参考[bridge](bridge.md)

### Disable the default bridge network
可以disable默认的`bridge`网络。
修改daemon.json文件
```json
"bridge": "none",
"iptables": "false"
```
然后重启docker使上述配置生效。

也可以在启动docker daemon的时候添加参数`--bridge=none --iptables=false`来disable默认的`bridge`网络。

## User-defined networks

### Bridge networks
`bridge`是Docker网络中最常用的网络类型。
`bridge`型网络和默认的名为`bridge`的网络相似，新增了新的特性，去除了旧有的功能。

如下命令创建一个`bridge`类型的网络，网络的名字是`isolated_nw`。
```sh
# docker network create --driver bridge isolated_nw
f933c9774fabc2a9522ec6e5a4d1058e5bd499338ca29a9dd33791eea6c9b0fa
# docker inspect isolated_nw
[
    {
        "Name": "isolated_nw",
        "Id": "f933c9774fabc2a9522ec6e5a4d1058e5bd499338ca29a9dd33791eea6c9b0fa",
        "Created": "2017-12-28T21:06:23.617232043+08:00",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": {},
            "Config": [
                {
                    "Subnet": "172.18.0.0/16",
                    "Gateway": "172.18.0.1"
                }
            ]
        },
        "Internal": false,
        "Attachable": false,
        "Ingress": false,
        "ConfigFrom": {
            "Network": ""
        },
        "ConfigOnly": false,
        "Containers": {},
        "Options": {},
        "Labels": {}
    }
]
```
创建网络之后，可以创建容器，通过--network=<NETWORK>指定网络:
```sh
# docker run --network=isolated_nw -itd --name=container3 busybox
90a7bb178e7bbf728aedadd64e28b1e85af60703b29dd1346c9c2b04475e0cea
```

```sh
# docker inspect isolated_nw
[
    {
        "Name": "isolated_nw",
        "Id": "f933c9774fabc2a9522ec6e5a4d1058e5bd499338ca29a9dd33791eea6c9b0fa",
        "Created": "2017-12-28T21:06:23.617232043+08:00",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": {},
            "Config": [
                {
                    "Subnet": "172.18.0.0/16",
                    "Gateway": "172.18.0.1"
                }
            ]
        },
        "Internal": false,
        "Attachable": false,
        "Ingress": false,
        "ConfigFrom": {
            "Network": ""
        },
        "ConfigOnly": false,
        "Containers": {
            "90a7bb178e7bbf728aedadd64e28b1e85af60703b29dd1346c9c2b04475e0cea": {
                "Name": "container3",
                "EndpointID": "b33e0f03843ba8f5c5571edbc3c5268deec50f88e493e47959ba34517c2da79b",
                "MacAddress": "02:42:ac:12:00:02",
                "IPv4Address": "172.18.0.2/16",
                "IPv6Address": ""
            }
        },
        "Options": {},
        "Labels": {}
    }
]
```
## Exposing and publishing ports
In Docker networking，牵涉到端口号的有了两种机制，都适用于默认的`bridge`网络和自定义的`bridge`类型的网络。
* expose ports：
    * Dockerfile中使用`EXPOSE`指令。
    * Docker命令行中使用`--expose`参数：`docker run --expose`。
* publish ports：Docker命令行中使用`--publish`或者`--publish-all`参数。可以指定容器中哪个端口会放开，并且会将容器的端口映射到宿主机上的一个端口（大于30000的随机端口，当然也可以指定宿主机的端口）。如下命令：
```sh
$ docker run -it -d -p 80 nginx

$ docker ps

64879472feea        nginx               "nginx -g 'daemon ..."   43 hours ago        Up About a minute   443/tcp, 0.0.0.0:32768->80/tcp   blissful_mclean

$ docker run -it -d -p 8080:80 nginx

$ docker ps

b9788c7adca3        nginx               "nginx -g 'daemon ..."   43 hours ago        Up 3 seconds        80/tcp, 443/tcp, 0.0.0.0:8080->80/tcp   goofy_brahmagupta
```

## 配置容器的Proxy Server
如果容器运行时需要使用HTTP，HTTPS，或者FTP proxy server，可以通过如下方式配置：
* 如果Docker>=17.07，可以通过配置Docker Client将proxy信息传入到容器中。
* 如果Docker>=17.06，通过设置容器的env variable。可以在构建镜像或者启动容器时设置。

### Configure the Docker Client
Docker Client的配置文件：~/.config.json
```json
{
  "proxies":
  {
    "default":
    {
      "httpProxy": "http://127.0.0.1:3001",
      "noProxy": "*.test.example.com,.example2.com"
    }
  }
}
```
如此设置Docker Client，当启动容器时会自动将这些环境变量设置到容器中。
### Set the environment variables manually
* HTTP_PROXY
* HTTPS_PROXY
* FTP_PROXY
* NO_PROXY

在Dockerfile中：ENV HTTP_PROXY "http://127.0.0.1:3001"
在命令行中：--env HTTP_PROXY "http://127.0.0.1:3001"
