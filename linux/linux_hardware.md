# 如何判断Linux系统运行在虚拟机或者物理机上
* dmesg | grep -i virtual
* dmidecode -s system-product-name
* lshw -class system