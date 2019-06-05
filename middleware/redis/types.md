# Redis数据结构类型
## 数据结构类型和编码方式
Redis的值有多种数据类型，针对不同的数据类型都有多种内部编码方式：
* string
    * raw: >39bytes
    * embstr: <=39bytes
    * int: 8bytes
* list：存储多个有序的字符串
    * linkedlist
    * quicklist
    * ziplist
* hash
    * hashtable
    * ziplist
* set
    * hashtable
    * intset
* zset
    * skiplist
    * ziplist
* bitmap
* hyperloglog
* geo

## 各数据结构特点
* list：元素是有序的，根据下标排序，可以重复，可以通过索引下标的形式获取元素。
* set：元素是无序的，不可重复，不能通过索引下标的形式获取元素。
* zset：元素有序的，根据score排序，不可重复。

## 应用场景
* list：时间轴、消息队列
* set： 标签
* zset：排行榜
