# aufs
AUFS是一种**Union File System**，所谓UnionFS就是**把不同物理位置的目录合并mount到同一个目录中**。

UnionFS的一个最主要的应用是，把一张CD/DVD和一个硬盘目录给联合mount在一起，然后，你就可以对这个只读的CD/DVD上的文件进行修改。当然，修改的文件存于硬盘上的目录里。

AUFS又叫Another UnionFS，后来叫Alternative UnionFS，后来可能觉得不够霸气，叫成Advance UnionFS。


