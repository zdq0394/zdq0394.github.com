# USER and WORKDIR
## USER
```
USER <user>[:<group>]
```
或者
```
USER <UID>[:<GID>]
```

USER指令设定下列情况下的user和group（可选）。
1. 运行image
2. USER定义之后的RUN，CMD和ENTRYPOINT指令。

## WORKDIR
```
WORKDIR /path/to/workdir
```