# Redis HyperLogLog
Redis在2.8.9版本添加了HyperLogLog结构。

Redis HyperLogLog是用来做**基数统计**的算法，HyperLogLog的优点是，在输入元素的数量或者体积非常非常大时，计算基数所需的空间总是固定的、并且是很小的。

在Redis里面，每个HyperLogLog键只需要花费12KB内存，就可以计算接近2^64个不同元素的基数。这和计算基数时，元素越多耗费内存就越多的集合形成鲜明对比。但是，因为 HyperLogLog只会根据输入元素来计算基数，而不会储存输入元素本身，所以HyperLogLog不能像集合那样，返回输入的各个元素。

## 什么是基数?
比如数据集 {1, 3, 5, 7, 5, 7, 8}， 那么这个数据集的基数集为 {1, 3, 5 ,7, 8}, 基数(不重复元素)为5。 **基数估计就是在误差可接受的范围内，快速计算基数。**

## 示例
```
redis 127.0.0.1:6379> PFADD runoobkey "redis"

1) (integer) 1

redis 127.0.0.1:6379> PFADD runoobkey "mongodb"

1) (integer) 1

redis 127.0.0.1:6379> PFADD runoobkey "mysql"

1) (integer) 1

redis 127.0.0.1:6379> PFCOUNT runoobkey

(integer) 3
```

## Redis HyperLogLog 命令
* PFADD key element [element ...]：添加指定元素到HyperLogLog中。
* PFCOUNT key [key ...]：返回给定HyperLogLog的基数估算值。
* PFMERGE destkey sourcekey [sourcekey ...]：将多个HyperLogLog合并为一个HyperLogLog。
