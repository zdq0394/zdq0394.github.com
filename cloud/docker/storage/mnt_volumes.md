# Volumes 的使用
Volumes是对容器产生和使用的数据进行持久化的首选机制。
Bind mounts依赖于宿主机的文件目录；Volumes完全由docker管理。

![](pics/tom-volume.png)

与bind mounts相比，volumes有一下优势：
* Volumes更容易备份和迁移。
* 可以通过Docker CLI和Docker API管理volumes。
* Volumes既可以在Linux容器又可以在Windows容器中使用。
* Volumes可以更安全的在多个容器中共享。
* Volume drivers可以将数据存储在远端或者云端服务器，可以加密。
* 新的volume中的内容可以很容易被容器pre-populated。

Volumes使用`rprivate` bind 级联。对volumes来说，Bind propagation不能配置。

## -v还是--mount
Docker 17.06以前，`-v`或者`--volume`在独立的容器上使用，`--mount`在services上使用。
从17.06开始，`--mount`也可以在独立的容器上使用。

### -v或者--volume
包含三部分，冒号（`:`）分隔。
* volume name
* 挂在到容器中的路径（文件或者目录路径）
* 可选的，volume的权限。可以由多个权限，由逗号分隔。

### --mount
包含多个key-value对，由逗号分隔。
* type：mount类型（bind，volume或者tmpfs），这里是volume。
* source： 或者src，volume name
* destination：或者dst/target，容器中的挂载点。
* readonly
* volume-opt：可以出现多次。

## 实践
### 创建并管理volumes

**Create a volume**：
```sh
$ docker volume create my-vol
```

**List volumes**:
```sh
$ docker volume ls

local               my-vol
```

**Inspect a volume**:
```sh
$ docker volume inspect my-vol
[
    {
        "Driver": "local",
        "Labels": {},
        "Mountpoint": "/var/lib/docker/volumes/my-vol/_data",
        "Name": "my-vol",
        "Options": {},
        "Scope": "local"
    }
]
```

** Remove a volume**
```sh
$ docker volume rm my-vol
```

### Start a container with a volume
如果启动容器时挂在一个不存在的volume，volume会自动创建。
**--mount**
```sh
$ docker run -d \
  -it \
  --name devtest \
  --mount source=myvol2,target=/app \
  nginx:latest
```

**-v/--volume**
```sh
$ docker run -d \
  -it \
  --name devtest \
  -v myvol2:/app \
  nginx:latest
```

使用`docker inspect devtest`命令查看是否创建并正确挂载了volume:
```json
"Mounts": [
    {
        "Type": "volume",
        "Name": "myvol2",
        "Source": "/var/lib/docker/volumes/myvol2/_data",
        "Destination": "/app",
        "Driver": "local",
        "Mode": "",
        "RW": true,
        "Propagation": ""
    }
],
```

### Stop the container and remove the volume
```sh
$ docker container stop devtest

$ docker container rm devtest

$ docker volume rm myvol2
```

### Start a service with wolumes
如果创建一个服务时定义一个volume,那么每个service container都将使用它自己的本地volume。
如果使用volume driver是`local`，那么不能共享数据。
```sh
$ docker service create -d \
  --replicas=4 \
  --name devtest-service \
  --mount source=myvol2,target=/app \
  nginx:latest
```

使用命令`docker service ps devtest-service`查看服务是否在运行
```sh
$ docker service ps devtest-service

ID                  NAME                IMAGE               NODE                DESIRED STATE       CURRENT STATE            ERROR               PORTS
4d7oz1j85wwn        devtest-service.1   nginx:latest        moby                Running             Running 14 seconds ago   
```
删除服务将删除所有的tasks：

```sh
$ docker service rm devtest-service
```

**Service不支持--volume参数**

### Populate a volume using a container
如果一个容器创建了一个新的volume，并且容器中对应的将要挂载的目录中有文件后者目录存在，那么目录中的内容会首先拷贝到volume中，然后，容器才mount并使用这个volume；

其它容器，挂载了这个volume之后将看到同样的内容。

### Use Readonly volume
```sh
$ docker run -d \
  -it \
  --name=nginxtest \
  --mount source=nginx-vol,destination=/usr/share/nginx/html,readonly \
  nginx:latest
```

```sh
$ docker run -d \
  -it \
  --name=nginxtest \
  -v nginx-vol:/usr/share/nginx/html:ro \
  nginx:latest
```

### Use a volume driver

**初始化**

首先在宿主机上安装**vieux/sshfs**
```sh
$ docker plugin install --grant-all-permissions vieux/sshfs
```
**Create a volume using a volume driver**
```sh
$ docker volume create --driver vieux/sshfs \
  -o sshcmd=test@node2:/home/test \
  -o password=testpassword \
  sshvolume
```
**Start a container which creates a volume using a volume driver**
```sh
$ docker run -d \
  -it \
  --name sshfs-container \
  --volume-driver vieux/sshfs \
  --mount src=sshvolume,target=/app,volume-opt=sshcmd=test@node2:/home/test,volume-opt=password=testpassword \
  nginx:latest
```





