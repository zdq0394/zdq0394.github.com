# OCI运行时规范
OCI运行时规范规定了3个方面的内容：
* 配置文件（configuration）
* 执行上下文（execution environment）
* 容器生命周期（lifecycle of a container）

## 容器configuration
一个容器的`configuration`是一个json文件：config.json；描述了支持的platform和创建容器所需要的信息。
Configuration文件(config.json)包含了：
* 要运行的进程
* 要注入的环境变量
* 要使用的sandbox特性

### pecification version
* ociVersion

### Root
Root：容器的root filesystem。

包含两个子field：
* path：指向容器的root filesystem的路径。
* readonly：默认false。
``` json
"root": {
    "path": "rootfs",
    "readonly": true
}
```

### Mounts
除了root之外的mounts。运行时将按照顺序执行mount操作。

包含三个子field：
* destination, 容器的挂载点, path inside container。
* source, A device name或者一个文件或者一个目录。
* options,
* type, 将要mount的文件系统。

```json
"mounts": [
    {
        "destination": "/tmp",
        "type": "tmpfs",
        "source": "tmpfs",
        "options": ["nosuid","strictatime","mode=755","size=65536k"]
    },
    {
        "destination": "/data",
        "type": "none",
        "source": "/volumes/testing",
        "options": ["rbind","rw"]
    }
]
```

### Process
容器进程。
* terminal
* consoleSize
    * height
    * width
* cwd
* env
* args

### User
* uid
* gid
* additionalGids

```json
"process": {
    "terminal": true,
    "consoleSize": {
        "height": 25,
        "width": 80
    },
    "user": {
        "uid": 1,
        "gid": 1,
        "additionalGids": [5, 6]
    },
    "env": [
        "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
        "TERM=xterm"
    ],
    "cwd": "/root",
    "args": [
        "sh"
    ],
    "apparmorProfile": "acme_secure_profile",
    "selinuxLabel": "system_u:system_r:svirt_lxc_net_t:s0:c124,c675",
    "noNewPrivileges": true,
    "capabilities": {
        "bounding": [
            "CAP_AUDIT_WRITE",
            "CAP_KILL",
            "CAP_NET_BIND_SERVICE"
        ],
       "permitted": [
            "CAP_AUDIT_WRITE",
            "CAP_KILL",
            "CAP_NET_BIND_SERVICE"
        ],
       "inheritable": [
            "CAP_AUDIT_WRITE",
            "CAP_KILL",
            "CAP_NET_BIND_SERVICE"
        ],
        "effective": [
            "CAP_AUDIT_WRITE",
            "CAP_KILL"
        ],
        "ambient": [
            "CAP_NET_BIND_SERVICE"
        ]
    },
    "rlimits": [
        {
            "type": "RLIMIT_NOFILE",
            "hard": 1024,
            "soft": 1024
        }
    ]
}
```

### Hostname
* hostname

### Hooks
* prestart
* poststart
* poststop

Hooks包含四个属性：
* path，runtime必须在runtime namespace中resolve该路径。
* args
* env
* timeout

```json
 "hooks": {
        "prestart": [
            {
                "path": "/usr/bin/fix-mounts",
                "args": ["fix-mounts", "arg1", "arg2"],
                "env":  [ "key1=value1"]
            },
            {
                "path": "/usr/bin/setup-network"
            }
        ],
        "poststart": [
            {
                "path": "/usr/bin/notify-start",
                "timeout": 5
            }
        ],
        "poststop": [
            {
                "path": "/usr/sbin/cleanup.sh",
                "args": ["cleanup.sh", "-f"]
            }
        ]
    }
```

[容器配置文件例子](container_configurations_example.md)
## 执行环境
执行环境定义了容器中要启动的进程具有一致的执行上下文，而不论运行在什么的OCI-runtime上。

## 容器生命周期
容器生命周期制定了容器可以被OCI-runtime执行的操作以及容器状态的转换。
### State
* ociVersion
* id
* status
    * creating
    * created
    * running
    * stopped
* pid：从主机上看到的container的process ID。
* bundle： 指向bundle directoy的绝对目录。这样运行时可以找到容器的配置数据和root filesystem。
* annotations: 容器的附加数据。

```json
{
    "ociVersion": "0.2.0",
    "id": "oci-container1",
    "status": "running",
    "pid": 4422,
    "bundle": "/containers/redis",
    "annotations": {
        "myKey": "myValue"
    }
}
```
### Lifecycle
容器从创建到退出的整个时间线。
1. OCI Runtime的create命令被调用，并且接受2个参数：
    * 指向bundle的reference
    * 容器ID
2. 容器的运行时“环境变量”被创建——根据config.json。如果创建失败，产生ERROR。该阶段不会运行user-specified的程序。该步骤之后，对config.json进行的更新不会影响容器。
3. OCI Runtime的start命令被调用，并且接受参数：container ID。
4. OCI Runtime调用prestart hooks。如果prestart hooks调用失败，则产生ERROR，并且stop container，然后进行step 9。
5. OCI Runtime运行user-specified的程序。
6. OCI Runtime调用poststart hooks。如果某个poststart hook调用失败，运行时记录Warning日志，但是后续操作继续进行。
7. 容器的进程退出——erroring、exiting或者crashing或者容器的kill命令被调用。
8. OCI Runtime的delete命令被调用，接受参数：container ID。
9. 容器被destroy。
10. OCI Runtime调用poststop hooks。如果某个poststop hook失败，运行时记录Warning日志，但是剩下的hooks会继续进行。

### Errors
发生error要终止操作，并回滚状态。
### Warning
记录warning日志不改变操作流程，操作继续进行，就像warning从没有发生过。

### 操作
* query state： state <container-id>
* create： create <container-id> <path-to-bundle>
* start： start <container-id>
* kill： kill <container-id> <signal>
* delete： delete <container-id>

