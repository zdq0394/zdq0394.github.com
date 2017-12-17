# tmpfs 的使用
**Volumes**和**bind mounts**默认都是把数据存储在宿主机的文件系统中。

**tmpfs**将数据存储在宿主机的内存中。当容器停止的时候，内存中的数据也删除；如果容器commit，内存中的数据不会保存。

![](pics/tom-tmpfs.png)

## --tmpfs 还是 --mount
Docker 17.06以前，`--tmpfs`在独立的容器上使用，`--mount`在services上使用。
从17.06开始，`--mount`也可以在独立的容器上使用。

### --tmpfs
没有任何配置项。

### --mount
包含多个key-value对，由逗号分隔。
* type：mount类型（bind，volume或者tmpfs），这里是tmpfs。
* destination：或者dst/target，容器中的挂载点。
* tmpfs-size：Size of the tmpfs mount in bytes.
* tmpfs-mode：File mode of the tmpfs in octal. For instance, 700 or 0770. Defaults to 1777 or world-writable.

### Limitations of tmpfs containers
* tmpfs mounts **cannot** be shared among containers.
* tmpfs mounts only work on **Linux containers**, and not on Windows containers.

## 实践
### Use a tmpfs mount in a container
```sh
$ docker run -d \
  -it \
  --name tmptest \
  --mount type=tmpfs,destination=/app \
  nginx:latest
```

```sh
$ docker run -d \
  -it \
  --name tmptest \
  --tmpfs /app \
  nginx:latest
```
