# Virtual Box虚拟机使用
## 时间同步
### 方式一（验证过）
* 关闭时间同步：
VBoxManage setextradata <虚拟机名/虚拟机UUID> "VBoxInternal/Devices/VMMDev/0/Config/GetHostTimeDisabled" "1"
* 打开时间同步：
VBoxManage setextradata <虚拟机名/虚拟机UUID> "VBoxInternal/Devices/VMMDev/0/Config/GetHostTimeDisabled" "0"
### 方式二（未验证）
* 关闭时间同步：
vboxmanage guestproperty set <虚拟机名/虚拟机UUID> --timesync-set-stop
* 打开时间同步：
vboxmanage guestproperty set <虚拟机名/虚拟机UUID> --timesync-set-start