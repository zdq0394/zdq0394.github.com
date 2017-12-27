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




