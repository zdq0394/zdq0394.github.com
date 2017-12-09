# Dockerfile
## 概览
Docker daemon可以读取**Dockerfile**中的指令自动的构建镜像。
一个Dockerfile就是一个文本文档，其中包含了可以通过命令行执行以组合一个镜像的命令。
通过**docker build**，可以创建自动构建：相继执行相关的命令行指令。

## 用法
命令**docker build**从一个**Dockerfile**和一个**context**构建一个镜像。

一个构建的**context**就是一个文件集合。制定文件集合有2种方式：
* PATH：本地文件目录及其子目录
* URL：git仓库及其submodules

执行docker build命令的是**docker daemon**，不是CLI。所以build流程的第一步就是将整个context发送到docker daemon。

一般情况下，**context**从一个空文件夹开始，然后在该文件夹下创建**Dockerfile**，然后只把需要的文件加入到context中。

可以通过Dockerfile中指令使用上下文中的文件，比如COPY指令。为了提高构建的性能，可以把用不到文件exclude掉，通过在context中增加**.dockerignore**文件。

Dockerfile一般命名为**Dockerfile**，并放在上下文的根目录下。也可以通过"-f"指定**本地文件系统任意位置**的Dockerfile。

``` sh
docker build -f /path/to/a/Dockerfile .
```

可以通过"-t"指定镜像的tag，可以指定多个"-t"标识。

Docker daemon逐条执行**Dockerfile**中的指令，并将每条指令的结果commit，从而构建一个**中间**镜像，直至最终输出最终镜像。 Dockerdaemon会自动清理context。

Dockerfile中的每条指令都是独立的，产生一个新的image。所以指令**RUN cd /tmp**没有任何意义，对下一条指令也没有影响。

Docker会尽可能的利用cached的中间镜像以加快构建速度。

## Format
Dockerfile中命令的格式如下：
``` Dockerfile
# Comment
INSTRUCTION arguments
```
指令**instruction**是不区分大小写的。一般情况下，INSTRUCTION都是大写，arguments小写。

Docker daemon按照顺序执行**Dockerfile**中的指令。一个Dockerfile必须从`FROM`指令开始。 
`FROM`指令定义了Base Image。
`FROM`之前能且仅能有若干个`ARG`指令。`ARG`定义只能`FROM`指令中使用的参数。

以`#`开头的是**注释**；除非该行是合法的**parser directive**。

## Parser directive
**Parser directive**是可选的，影响**随后的指令**的处理方式。

**Parser directive**不会添加一个**镜像层**，也不会显示为一个build step。

Parser directives形式如注释：
```
# directive=value
```

一个directive只能使用一次。

所有的Parser directives必须出现在Dockerfile的**最前面**。
任何**注释**、**空行**或者**指令**之后出现的directive格式的行都**不会**被认为是directive，都认为是**注释**。

Parser directives不区分大小写。一般作**小写**，并且在parser directives的最后跟着一个空行。与`ARG`或者`FROM`分隔开。

### escape
**escape**是一个parser directive。
```
# escape=\ (backslash)
```

```
# escape=` (backtick)
```

## Environment replacement




## .dockerignore文件




