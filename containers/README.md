# 容器技术

## 基础
* [namespace](core\namespace.md)
* [cgroup](core\cgroup.md)
* [unionfs-overlayfs](core\overlayfs.md)

## Open Container Initiative

### 官方文档
* [Runtime-Spec](https://github.com/opencontainers/runtime-spec/blob/master/spec.md)
* [Image-Spec](https://github.com/opencontainers/image-spec/blob/master/spec.md)
* [Distribution-Spec](https://github.com/opencontainers/distribution-spec/blob/master/spec.md)

### 运行时
* [Runtime规范](oci\runtime_spec.md)
* [Filesystem Bundle](oci\filesystem_bundle.md)
* [Runc](oci\runc.md)

### 镜像
* [Image规范](oci\image_spec.md)

### 分发
* [分发规范](oci\distribution_spec.md)

### OCI
* [Containerd](oci\containerd.md)
* [FAQ](oci\faq.md)

## Docker

### Docker基础 
* [概述](docker/base/overview.md)
* [镜像及其layer存储分析](docker/core/image_layout.md)
* [容器及其layer存储分析]docker/(core/container_layout.md)
* [Containerd中容器context](docker/core/containerd_runc.md)

### Dockerfile
* [概述](docker/dockerfile/df.md)
    * [FROM](docker/dockerfile/from.md)
    * [RUN](docker/dockerfile/run.md)
    * [CMD](docker/dockerfile/cmd.md)
    * [LABEL](docker/dockerfile/label.md)
    * [EXPOSE](docker/dockerfile/expose.md)
    * [ENV](docker/dockerfile/env.md)
    * [ADD和COPY](docker/dockerfile/add_and_copy.md)
    * [Entrypoint](docker/dockerfile/entrypoint.md)
    * [Volume](docker/dockerfile/volume.md)
    * [USER和WORKDIR](docker/dockerfile/user_and_workdir.md)
    * [ARG](docker/dockerfile/arg.md)
    * [ONBUILD](docker/dockerfile/onbuild.md)
    * [STOPSIGNAL](docker/dockerfile/stop_signal.md)
    * [HEALTHCHECK](docker/dockerfile/healthcheck.md)
    * [SHELL](docker/dockerfile/shell.md)

### Docker存储

#### 系统存储
* [Storage Drivers概述](docker/storage/sd_drivers.md)
    * [devicemapper](docker/storage/sd_devicemapper.md)
    * [overlay2](docker/storage/sd_overlay2.md)
* Storage Driver实践分析
    * [Ubuntu 14.04下的Docker AUFS存储](docker/storage/action_aufs_ubuntu_14_04.md)
* [如何选择Storage driver](docker/storage/sd_select.md)

#### 数据存储
* [Docker数据存储](docker/storage/mnt_overview.md)
    * [Volumes使用](docker/storage/mnt_volumes.md)
    * [Bind mounts使用](docker/storage/mnt_bindmounts.md)
    * [tmpfs使用](docker/storage/mnt_tmpfs.md)

### Docker网络
* [Docker网络概述](docker/networks/overview.md)
* [Docker Bridge网络](docker/networks/bridge.md)
* [Docker network命令](docker/networks/commands.md)

### Docker Registry
* [概述](docker/registry/overview.md)
* [全面理解Registry](docker/registry/understanding_the_registry.md)
* [部署Registry](docker/registry/deploy_registry_server.md)
* [详细配置Registry](docker/registry/configure_a_registry.md)
* [Registry Mirror](docker/registry/registry_as_a_pull_through_cache.md)
* [Registry通知系统](docker/registry/webhooks.md)
* [Registry存储driver](docker/registry/storage_driver.md)
* [Garbage collection](docker/registry/garbage_collection.md)
* Docker Registry OAuth
    * [Token authentication spec](docker/registry/token_authentication.md)
    * [Docker registry token scope and access](docker/registry/token_scope.md)
    * [OAuth2 token authentication](docker/registry/token_oauth2_authentication.md)
    * [Token authentication implementation](docker/registry/token_authentication_implementation.md)
