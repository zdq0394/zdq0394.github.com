# ENV
```
ENV <key> <value>
ENV <key>=<value> ...
```
**ENV**指令可以设置**环境变量**值。
环境变量可以被Dockerfile中后面的指令引用。

EVN指令的形式有两种：
``` 
ENV <key> <value>： 设置一个单一值，第一个空格之后的所有内容作为key的value，包括空格和引号。

ENV <key>=<value>： 一行可以设置多个kv对。

```

``` Dockerfile
ENV myName="John Doe" myDog=Rex\ The\ Dog \
    myCat=fluffy
```

``` Dockerfile
ENV myName John Doe
ENV myDog Rex The Dog
ENV myCat fluffy
```