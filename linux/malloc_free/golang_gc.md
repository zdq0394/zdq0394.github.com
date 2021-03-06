# golang gc
常见的垃圾回收算法有如下几种：
* 引用计数：对每个对象维护一个引用计数，当引用该对象的对象被销毁，引用计数减1，当引用计数减为0的时候，回收该对象。
    * 优点：对象可以很快的被回收，不会出现内存耗尽或者达到某个阈值时才回收。
    * 缺点：不能很好的处理循环引用，而且实时维护引用计数，有一定的代价。
    * 代表语言：Python，PHP，Swift
* 标记-清除：从根变量开始遍历所有引用的对象，引用的对象标记为“被引用”，没有被标记的对象进行回收。
    * 优点：解决了引用计数的缺点
    * 缺点：需要STW（Stop The World），出现应用卡顿。
    * 代表语言：Golang（三色标记法）
* 分代收集：按照对象生命周期长短划分为不同的代空间，生命和周期长的划入老年代，短的划入新生代。不同代有不同的回收算法和回收频率。
    * 优点：回收性能好
    * 缺点：算法复杂
    * 代表语言：Java
Golang的GC属于标记-清除。具体来说是并行的基于三色标记的标记清除算法，不需要长时间的STW。
Golang的GC算法更关注`低延迟`，而不是`高吞吐`。