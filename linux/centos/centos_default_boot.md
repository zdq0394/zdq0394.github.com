# CentOS7设置GRUB系统内核开机选单
## 方法一：（创建、查看、编辑、用命令设置）
根据/boot/目录内的文件,自动创建GRUB内核配置开机选单
```sh
grub2-mkconfig -o /boot/grub2/grub.cfg
```
说明：/boot/grub2/grub.cfg文件不可手工编辑

## 查看可选的GRUB内核配置开机选单
```sh
awk -F\' '$1=="menuentry " {print i++ " : " $2}' /etc/grub2.cfg
```
说明：/etc/grub2.cfg文件是一个文件链接，实际链接到/boot/grub2/grub.cfg

/etc/default/grub文件是可以编辑，保存了GRUB通用的变量设置

查看编辑/etc/default/grub文件，确保GRUB_DEFAULT=saved
```sh
vi /etc/default/grub
```

假设我们需要运行的内核版本为第0项，执行grub2-set-default0设置内核配置开机选单为第0项（第一个），执行grub2-editenv list确认设置成功（saved_entry=0）
```sh
grub2-set-default 0
grub2-editenv list
```