# Ubuntu 14.04下的Docker AUFS存储
查看docker目录，可见如下内容：
```sh
root@local:/var/lib/docker# ls
aufs  containers  graph  init  linkgraph.db  repositories-aufs  tmp  trust  volumes
```
* repositories-aufs： repo列表
* graph： docker context下的layers之间的关系
* aufs： 文件系统层面layers之间的关系

## 首先拉取两个镜像做测试：
1. busybox
```sh
root@local:/var/lib/docker/aufs# docker pull busybox
latest: Pulling from busybox
97d69bba9a9d: Pull complete 
789355058656: Pull complete 
Digest: sha256:e3789c406237e25d6139035a17981be5f1ccdae9c392d1623a02d31621a12bcc
Status: Downloaded newer image for busybox:latest
```
2. redis
```sh
root@local:/var/lib/docker# docker pull redis
latest: Pulling from redis
2e4125888032: Pull complete 
77fe44e7dc79: Pull complete 
e5bcc9ce9b77: Pull complete 
e4b18f28200c: Pull complete 
adcb27129429: Pull complete 
148cfbb17c8f: Pull complete 
c0f8939f779a: Pull complete 
3729e0036a74: Pull complete 
f450a2878ab6: Pull complete 
a2c7b0131633: Pull complete 
41f541aa23f6: Pull complete 
893c56607b58: Pull complete 
b7619ad72c9e: Pull complete 
b24a601bcb9d: Pull complete 
cdae54488c33: Pull complete 
c7d952921cec: Pull complete 
Digest: sha256:833c4cedada44a196c652da7151d5f716cef944f5d9f851fd9d04434e129608b
Status: Downloaded newer image for redis:latest
```

## 查看repositories-aufs:

``` json
{
    "Repositories":{
        "busybox":{
            "latest":"789355058656ec2ca0a856283e2597852ccd444548c9ef4fcbf8c9c24a73e169"
            },
        "redis":{
            "latest":"c7d952921cec16e2213a30b7e9251ae41d3388f8bb47a55115373eb8f5f86c0d"
            }
    }
}
```

文件是json格式，有两个repo：busybox和redis。每个repo都有一个镜像。每个镜像由tag和镜像的最上面一层的layer id组成。
比如redis，我们先看graph目录：
```sh
root@local:/var/lib/docker# ll graph
total 84
drwx------ 21 root root 4096 Dec 19 10:34 ./
drwx------  9 root root 4096 Dec 19 10:26 ../
drwx------  2 root root 4096 Dec 19 10:34 148cfbb17c8f4695253afa1a26d91c01f04d062d95d7e955c6093c9a744c1e07/
drwx------  2 root root 4096 Dec 19 10:34 2e4125888032d525ea7911decb974240d77d5946a00262bbabf6a765b28351c4/
drwx------  2 root root 4096 Dec 19 10:34 3729e0036a740d3154b22675958accc7182a43a3a1885a1af3ea2fe3d01edc34/
drwx------  2 root root 4096 Dec 19 10:34 41f541aa23f61e71734713a96b4e9051b1c069e0c7ce9f90ec5af9225782d87d/
drwx------  2 root root 4096 Dec 19 10:34 77fe44e7dc795ca45a75317956361c79a69e03f2e231eecabab43fb4828c1e02/
drwx------  2 root root 4096 Dec 19 10:24 789355058656ec2ca0a856283e2597852ccd444548c9ef4fcbf8c9c24a73e169/
drwx------  2 root root 4096 Dec 19 10:34 893c56607b58ceaf230a05b23bf0d623e25cdcdb3f294851c51aaadddd2ffa4a/
drwx------  2 root root 4096 Dec 19 10:03 97d69bba9a9d8406055d0fdc38a7f00162823ee5ca3751fc71531cb210204ff9/
drwx------  2 root root 4096 Dec 19 10:34 a2c7b01316337e88a14f8a0b7c3be69a3d97b2a53a2cea086c9df1e903687101/
drwx------  2 root root 4096 Dec 19 10:34 adcb27129429d01e1b72617a732163644ee7be9b031398c97c2e21987f78a608/
drwx------  2 root root 4096 Dec 19 10:34 b24a601bcb9d4e260f17cb62896fdac69879b9c9d1c20edf89148009bb7eabdd/
drwx------  2 root root 4096 Dec 19 10:34 b7619ad72c9ec5b3c9c46d8d97889980814a97429133efa4c9029d0a2377a053/
drwx------  2 root root 4096 Dec 19 10:34 c0f8939f779a9f6bcf63aa97be01909f3f12015b60d9aef29ff77d8c0c0bd517/
drwx------  2 root root 4096 Dec 19 10:34 c7d952921cec16e2213a30b7e9251ae41d3388f8bb47a55115373eb8f5f86c0d/
drwx------  2 root root 4096 Dec 19 10:34 cdae54488c335c13449ff5144e0314e70a800e123d8040d75cb232a9ac9d15f3/
drwx------  2 root root 4096 Dec 19 10:34 e4b18f28200c126f9d4e95cd987204b68dbc4dcc2b7729a43ae10fe5ecd6700e/
drwx------  2 root root 4096 Dec 19 10:34 e5bcc9ce9b776659b5d8a8dc4d1b4bccb0d3f5a9c3ec750f5e1aa5f58c3e5a4e/
drwx------  2 root root 4096 Dec 19 10:34 f450a2878ab6a2d234f3a5107205e5599dd3c75565d8fc360f5b7f889c0e78ed/
drwx------  2 root root 4096 Dec 19 10:34 _tmp/
```
目录下共有18个层，正好对应busybox和redis的18个层。
我们知道redis的latest镜像如下：
 "latest":"c7d952921cec16e2213a30b7e9251ae41d3388f8bb47a55115373eb8f5f86c0d"

```sh
root@local:/var/lib/docker# ls -la graph/c7d952921cec16e2213a30b7e9251ae41d3388f8bb47a55115373eb8f5f86c0d/
total 16
drwx------  2 root root 4096 Dec 19 10:34 .
drwx------ 21 root root 4096 Dec 19 10:34 ..
-rw-------  1 root root 1988 Dec 19 10:34 json
-rw-------  1 root root    1 Dec 19 10:34 layersize
```

json:
```json
{
    "id":"c7d952921cec16e2213a30b7e9251ae41d3388f8bb47a55115373eb8f5f86c0d","parent":"cdae54488c335c13449ff5144e0314e70a800e123d8040d75cb232a9ac9d15f3",
    "created":"2017-12-12T07:15:58.901779813Z","container":"cf72799c32e80417751c6657f680d42cef1f5a03befe10074860e9fdfa8d9709",
    "container_config":
    {
        "Hostname":"cf72799c32e8",
        "Domainname":"",
        "User":"",
        "Memory":0,
        "MemorySwap":0,
        "CpuShares":0,
        "Cpuset":"",
        "AttachStdin":false,
        "AttachStdout":false,
        "AttachStderr":false,
        "PortSpecs":null,
        "ExposedPorts":{"6379/tcp":{}},
        "Tty":false,
        "OpenStdin":false,
        "StdinOnce":false,
        "Env":["PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin","GOSU_VERSION=1.10","REDIS_VERSION=4.0.6","REDIS_DOWNLOAD_URL=http://download.redis.io/releases/redis-4.0.6.tar.gz","REDIS_DOWNLOAD_SHA=769b5d69ec237c3e0481a262ff5306ce30db9b5c8ceb14d1023491ca7be5f6fa"],
        "Cmd":["/bin/sh","-c","#(nop) ","CMD [\"redis-server\"]"],"Image":"sha256:03e433d6dc5431c878f412f8a65064556876c6dbad3393bd2d9cfff6ee66b794",
        "Volumes":{"/data":{}},
        "WorkingDir":"/data",
        "Entrypoint":["docker-entrypoint.sh"],
        "NetworkDisabled":false,
        "MacAddress":"",
        "OnBuild":[],
        "Labels":{}
    },
    "docker_version":"17.06.2-ce",
    "config":{
        "Hostname":"",
        "Domainname":"",
        "User":"",
        "Memory":0,
        "MemorySwap":0,
        "CpuShares":0,
        "Cpuset":"",
        "AttachStdin":false,
        "AttachStdout":false,
        "AttachStderr":false,
        "PortSpecs":null,
        "ExposedPorts":{"6379/tcp":{}},
        "Tty":false,
        "OpenStdin":false,
        "StdinOnce":false,
        "Env":["PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin","GOSU_VERSION=1.10","REDIS_VERSION=4.0.6","REDIS_DOWNLOAD_URL=http://download.redis.io/releases/redis-4.0.6.tar.gz","REDIS_DOWNLOAD_SHA=769b5d69ec237c3e0481a262ff5306ce30db9b5c8ceb14d1023491ca7be5f6fa"],
        "Cmd":["redis-server"],
        "Image":"sha256:03e433d6dc5431c878f412f8a65064556876c6dbad3393bd2d9cfff6ee66b794",
        "Volumes":{"/data":{}},
        "WorkingDir":"/data",
        "Entrypoint":["docker-entrypoint.sh"],
        "NetworkDisabled":false,
        "MacAddress":"",
        "OnBuild":[],
        "Labels":null
    },
    "architecture":"amd64",
    "os":"linux",
    "Size":0
}
```
json字段parent指出了上一层的id。如此一次可以找下去。直到最后一层。

``` json
{
    "id":"2e4125888032d525ea7911decb974240d77d5946a00262bbabf6a765b28351c4",
    "created":"2017-12-12T01:41:34.77099551Z",
    "container_config":
        {
            "Hostname":"",
            "Domainname":"",
            "User":"",
            "Memory":0,
            "MemorySwap":0,
            "CpuShares":0,
            "Cpuset":"",
            "AttachStdin":false,
            "AttachStdout":false,
            "AttachStderr":false,
            "PortSpecs":null,
            "ExposedPorts":null,
            "Tty":false,
            "OpenStdin":false,
            "StdinOnce":false,
            "Env":null,
            "Cmd":["/bin/sh -c #(nop) ADD file:e7ac45803c3ab9b7023933b75f5a88eda1f3edca97c7e462401860777cf312f7 in / "],"Image":"",
            "Volumes":null,
            "WorkingDir":"",
            "Entrypoint":null,
            "NetworkDisabled":false,
            "MacAddress":"",
            "OnBuild":null,
            "Labels":null
        },
    "Size":79146752
}
```

最后一层没有parent字段，结束。

## AUFS文件系统
**/var/lib/docker/aufs**目录下有3个子目录组成：
```sh
root@local:/var/lib/docker/aufs# ls -la
total 20
drwxr-xr-x  5 root root 4096 Dec 19 10:01 .
drwx------  9 root root 4096 Dec 19 10:26 ..
drwxr-xr-x 20 root root 4096 Dec 19 10:34 diff
drwxr-xr-x  2 root root 4096 Dec 19 10:34 layers
drwxr-xr-x 20 root root 4096 Dec 19 10:34 mnt
```
我们从layers看：
```sh
root@local:/var/lib/docker/aufs# ls -la layers/
total 72
drwxr-xr-x 2 root root 4096 Dec 19 10:34 .
drwxr-xr-x 5 root root 4096 Dec 19 10:01 ..
-rw-r--r-- 1 root root  325 Dec 19 10:34 148cfbb17c8f4695253afa1a26d91c01f04d062d95d7e955c6093c9a744c1e07
-rw-r--r-- 1 root root    0 Dec 19 10:34 2e4125888032d525ea7911decb974240d77d5946a00262bbabf6a765b28351c4
-rw-r--r-- 1 root root  455 Dec 19 10:34 3729e0036a740d3154b22675958accc7182a43a3a1885a1af3ea2fe3d01edc34
-rw-r--r-- 1 root root  650 Dec 19 10:34 41f541aa23f61e71734713a96b4e9051b1c069e0c7ce9f90ec5af9225782d87d
-rw-r--r-- 1 root root   65 Dec 19 10:34 77fe44e7dc795ca45a75317956361c79a69e03f2e231eecabab43fb4828c1e02
-rw-r--r-- 1 root root   65 Dec 19 10:03 789355058656ec2ca0a856283e2597852ccd444548c9ef4fcbf8c9c24a73e169
-rw-r--r-- 1 root root  715 Dec 19 10:34 893c56607b58ceaf230a05b23bf0d623e25cdcdb3f294851c51aaadddd2ffa4a
-rw-r--r-- 1 root root    0 Dec 19 10:03 97d69bba9a9d8406055d0fdc38a7f00162823ee5ca3751fc71531cb210204ff9
-rw-r--r-- 1 root root  585 Dec 19 10:34 a2c7b01316337e88a14f8a0b7c3be69a3d97b2a53a2cea086c9df1e903687101
-rw-r--r-- 1 root root  260 Dec 19 10:34 adcb27129429d01e1b72617a732163644ee7be9b031398c97c2e21987f78a608
-rw-r--r-- 1 root root  845 Dec 19 10:34 b24a601bcb9d4e260f17cb62896fdac69879b9c9d1c20edf89148009bb7eabdd
-rw-r--r-- 1 root root  780 Dec 19 10:34 b7619ad72c9ec5b3c9c46d8d97889980814a97429133efa4c9029d0a2377a053
-rw-r--r-- 1 root root  390 Dec 19 10:34 c0f8939f779a9f6bcf63aa97be01909f3f12015b60d9aef29ff77d8c0c0bd517
-rw-r--r-- 1 root root  975 Dec 19 10:34 c7d952921cec16e2213a30b7e9251ae41d3388f8bb47a55115373eb8f5f86c0d
-rw-r--r-- 1 root root  910 Dec 19 10:34 cdae54488c335c13449ff5144e0314e70a800e123d8040d75cb232a9ac9d15f3
-rw-r--r-- 1 root root  195 Dec 19 10:34 e4b18f28200c126f9d4e95cd987204b68dbc4dcc2b7729a43ae10fe5ecd6700e
-rw-r--r-- 1 root root  130 Dec 19 10:34 e5bcc9ce9b776659b5d8a8dc4d1b4bccb0d3f5a9c3ec750f5e1aa5f58c3e5a4e
-rw-r--r-- 1 root root  520 Dec 19 10:34 f450a2878ab6a2d234f3a5107205e5599dd3c75565d8fc360f5b7f889c0e78ed
```
共18个层，每层是一个文件，文件内容包含了该层下面各个层的ID。还是从redis:latest的最上一层`c7d952921cec16e2213a30b7e9251ae41d3388f8bb47a55115373eb8f5f86c0d`开始：

```sh
root@local:/var/lib/docker/aufs# cat layers/c7d952921cec16e2213a30b7e9251ae41d3388f8bb47a55115373eb8f5f86c0d 
cdae54488c335c13449ff5144e0314e70a800e123d8040d75cb232a9ac9d15f3
b24a601bcb9d4e260f17cb62896fdac69879b9c9d1c20edf89148009bb7eabdd
b7619ad72c9ec5b3c9c46d8d97889980814a97429133efa4c9029d0a2377a053
893c56607b58ceaf230a05b23bf0d623e25cdcdb3f294851c51aaadddd2ffa4a
41f541aa23f61e71734713a96b4e9051b1c069e0c7ce9f90ec5af9225782d87d
a2c7b01316337e88a14f8a0b7c3be69a3d97b2a53a2cea086c9df1e903687101
f450a2878ab6a2d234f3a5107205e5599dd3c75565d8fc360f5b7f889c0e78ed
3729e0036a740d3154b22675958accc7182a43a3a1885a1af3ea2fe3d01edc34
c0f8939f779a9f6bcf63aa97be01909f3f12015b60d9aef29ff77d8c0c0bd517
148cfbb17c8f4695253afa1a26d91c01f04d062d95d7e955c6093c9a744c1e07
adcb27129429d01e1b72617a732163644ee7be9b031398c97c2e21987f78a608
e4b18f28200c126f9d4e95cd987204b68dbc4dcc2b7729a43ae10fe5ecd6700e
e5bcc9ce9b776659b5d8a8dc4d1b4bccb0d3f5a9c3ec750f5e1aa5f58c3e5a4e
77fe44e7dc795ca45a75317956361c79a69e03f2e231eecabab43fb4828c1e02
2e4125888032d525ea7911decb974240d77d5946a00262bbabf6a765b28351c4
```
我们可以逐层查看下去，最后一层是空的：
```sh
root@local:/var/lib/docker/aufs# cat layers/2e4125888032d525ea7911decb974240d77d5946a00262bbabf6a765b28351c4
```
