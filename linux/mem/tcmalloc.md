# TCMalloc: Thread-Caching Malloc
## 术语
* PageHeap
* CentralCache
* CentralFreeList
* ThreadCache
* FreeList
* Page： 默认8K
* Span：连续的pages
* Class：一小块连续的字节。8,16,32,48,...,256K等多个class。
## 对象分类
* 小对象: (0, 256K]：小对象从Thread Cache/Central Cache/PageHeap中分配
* 中对象: (256K, 1M]：中对象从PageHeap中分配
* 大对象: (1M, +++)：大对象从PageHeap中分配
## PageHeap
PageHeap缓存包含两部分：
1. 1~128pages, Span List per pages size
2. more than 128pages, Red Black Tree sorted by size
类型1用来分配中对象，类型2用来分配大对象。
## Central Cache
Central Cache是一个数组，每个元素是针对一个Class Size的Central Free List。

Central Free List是一个2级结构。Central Free List首先是一系列Span的列表，每个Span是具有Class Size大小的objects list。
## Thread Cache
Thread Cache中每个Class Size对应一个FreeList。
## Reference
* http://goog-perftools.sourceforge.net/doc/tcmalloc.html