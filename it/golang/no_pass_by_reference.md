# Go语言中没有引用传递
Go语言中没有**引用变量**，所以Go语言就没有**引用传递**的函数调用的语法。

## 什么时引用变量
在像 C++ 这样的语言中你可以给一个已经存在的变量定义一个别名，这个别名就被称为引用变量。

```c++
#include <stdio.h>

int main() {
        int a = 10;
        int &b = a;
        int &c = b;

        printf("%p %p %p\n", &a, &b, &c); // 0x7ffe114f0b14 0x7ffe114f0b14 0x7ffe114f0b14
        return 0;
}
```
你可以看到上面a、b、c 都指向了相同的内存地址，向a写入数据将会更改b、c的内容。这当你想在不同作用域（即函数调用）里定义引用变量的时候就显得十分的关键。


## Go语言中并没有引用变量
与C++不同，Go语言中每一个定义的变量都占据一个唯一的内存地址。

```go
package main

import (
    "fmt"
)

func main() {
    var a int
    var b = &a
    var c = &a

    fmt.Println(&a, &b, &c) //0xc0420361d0 0xc04204e018 0xc04204e020
}
```

在Go语言中，不可能创建2个变量而这2个变量却拥有相同的内存地址。Go语言是允许创建2个变量它们的内容是同一个指向相同地址的指针，但是这与两个变量共享同一个内存地址完全是两回事。

```go
package main

import "fmt"

func main() {
        var a int
        var b, c = &a, &a
        fmt.Println(b, c)   // 0x1040a124 0x1040a124
        fmt.Println(&b, &c) // 0x1040c108 0x1040c110
}
```

在这个例子中b、c持有的相同的值是a的地址，然而b、c他们自己的存储则存储在各自唯一的地址中的，更新b的内容 是不会对c的内容产生影响的。

## Maps和Channels也不是引用变量

``` go
package main

import "fmt"

func fn(m map[int]int) {
        m = make(map[int]int)
}

func main() {
        var m map[int]int
        fn(m)
        fmt.Println(m == nil)
}

```
如果他们是引用变量，那么下面这段程序将打印false。那map是什么呢？[Map is not references](map_isnot_reference.md)
