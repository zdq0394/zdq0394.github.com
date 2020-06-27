# NVIDAI GPU
## Tesla Driver
### 环境准备
NVIDIA Telsa GPU的驱动在安装过程中需要编译kernel module，需要安装gcc和kernel devel。
```sh
#> yum install gcc kernel-devel-($uname -r) kernel-headers
```

### RPM安装
1. 登录[NVIDIA驱动官网](https://www.nvidia.com/Download/Find.aspx)
2. 选择对应的RPM包的操作系统，复制链接
```sh
#> wget http://us.download.nvidia.com/tesla/440.33.01/nvidia-driver-local-repo-rhel7-440.33.01-1.0-1.x86_64.rpm
```
3. 运行安装软件包命令
```sh
#> rpm -i nvidia-driver-local-repo-rhel7-440.33.01_1.0-1_x86_64.rpm
```
4. 使用yum清理缓存
```sh
#> yum clean all
```
5. 使用yum安装驱动
```sh
#> yum install cuda-drivers
```
6. 使用reboot重启机器
7. 运行nvidia-smi验证是否安装成功

## CUDA
1. 登录[CUDA官方下载页面](https://developer.nvidia.com/cuda-75-downloads-archive)，按照系统和安装方式选择安装包。
2. 下载安装包
```sh
#> wget http://developer.download.nvidia.com/compute/cuda/7.5/Prod/local_installers/cuda-repo-rhel7-7-5-local-7.5-18.x86_64.rpm
```
3. 在CUDA安装包所在目录下运行如下命令
```sh
#> sudo rpm -i cuda-repo-rhel7-7-5-local-7.5-18.x86_64.rpm
#> sudo yum clean all
#> sudo yum install cuda
```
4. 在/usr/local/cuda/samples/1_Utilities/deviceQuery目录下执行make命令，编译出deviceQuery程序
5. 使用./deviceQuery命令运行deviceQuery程序

## 可能出现的问题
1. 安装CUDA时提示dkms依赖错误
安装额外依赖包EPEL（Extra Packages for Enterprise Linux），以CentOS7为例
```sh
#> yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
```
安装dkms
```sh
#> yum -y install dkms
```
2. 先安装NVIDIA Driver再安装CUDA后，再次使用nvidia-smi报错，报错信息为`Failed to initialize NVML: Driver/library version mismatch`

先排查 NVIDIA Driver 对应的 CUDA 版本是否对应，可以在驱动下载官网查看自己下载的驱动版本。
排除驱动版本不对的问题后，重启机器即可。
```sh
#> sudo reboot now
```