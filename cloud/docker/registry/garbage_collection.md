# Garbage collection
## 关于Garbage collection
在Docker registry的语境中，garbage collection是指从文件系统中删除不再被manifest引用的blobs的过程。Blobs包括layers和manifests。

## Run garbage collection
执行如下命令：
``` sh
bin/registry garbage-collect [--dry-run] /path/to/config.yml
```

config配置：
``` yaml
version: 0.1
storage:
  filesystem:
    rootdirectory: /registry/data
```