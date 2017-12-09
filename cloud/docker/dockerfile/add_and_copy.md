# ADD和COPY
## ADD
ADD有两种形式：
* ADD <src>... <dest>
* ADD ["<src>", ... , "<dest>"]

**ADD**指令复制文件、目录或者远程URL指定的文件到镜像的系统种dest路径
可以指定多个<src>，如果是文件或者目录，那么一定是相对于build context的。

src可以指定wildchards，匹配规则和Go的filepath.Match一致。

``` Dockerfile
ADD hom* /mydir/        # adds all files starting with "hom"
ADD hom?.txt /mydir/    # ? is replaced with any single character, e.g., "home.txt"
```

dest是一个绝对地址，或者相对与WORKDIR的地址。

所有的文件和目录的UID和GID都是0。


## COPY




## Differences