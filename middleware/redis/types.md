# Redis数据结构类型
## 数据结构类型和编码方式
Redis的值有多种数据类型，针对不同的数据类型都有多种内部编码方式：
* string
    * raw
    * embstr
    * int
* list
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

