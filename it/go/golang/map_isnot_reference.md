# If a map isn’t a reference variable, what is it?

Go map不是引用变量，也不是通过引用传递。
A map value is a pointer to a **runtime.hmap** structure.

## a map value的**类型**
如果这样一个语句：

```go
m := make(map[int]int)
```

编译器将会替换为：对runtime.makemap的调用:

```go
// makemap implements a Go map creation make(map[k]v, hint)
// If the compiler has determined that the map or the first bucket
// can be created on the stack, h and/or bucket may be non-nil.
// If h != nil, the map can be created directly in h.
// If bucket != nil, bucket can be used as the first bucket.
func makemap(t *maptype, hint int64, h *hmap, bucket unsafe.Pointer) *hmap
```
如你所见，runtime.makemap返回值的类型时一个指针：指向runtime.hmap structure。我们从一般的go代码中无法发现这点，但是我们可以确认map的值是一个**uintptr**一个机器**字**大小。

``` go
package main

import (
	"fmt"
	"unsafe"
)

func main() {
	var m map[int]int
	var p uintptr
	fmt.Println(unsafe.Sizeof(m), unsafe.Sizeof(p)) // 8 8 (linux/amd64)
}
```

## If maps are pointers, shouldn’t they be *map[key]value?

如果map时指针，为什么返回值是map[int]int，而不是*map[int]int？

是的，在最开始的时候是被写作指针的形式的：*map[int]int。我们把它去除了，因为我们发现从来没有人写过`map`，都是`*map`。

Arguably renaming the type from *map[int]int to map[int]int, while confusing because the type does not look like a pointer, was less confusing than a pointer shaped value which cannot be dereferenced.

## 结论

Maps和channels一样，与slices不同，实际是指向内部运行时类型的指针。

## 参考链接
* https://dave.cheney.net/2017/04/30/if-a-map-isnt-a-reference-variable-what-is-it