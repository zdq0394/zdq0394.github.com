# ENTRYPOINT
ENTRYPOINT有两种形式：
* ENTRYPOINT ["executable", "param1", "param2"] (**exec形式，推荐方式**)
* ENTRYPOINT command param1 param2 (**shell形式**)

**ENTRYPOINT**可以对一个可执行的容器（**a container that will run as an executable**）进行配置。
例如，下面的命令将启动一个nginx服务器，监听在80端口。
``` sh
docker run -i -t --rm -p 80:80 nginx
```
跟在“docker run <image>”之后的命令行参数将附加在"exec形式的ENTRYPOINT"的最后面，覆盖使用"CMD"指定的参数。如此，可以向ENTRYPOINT传递参数，比如“docker run <image> -d”将把参数“-d”传递给镜像中的ENTRYPOINT。

通过“docker run --entrypoint”可以覆盖Dockerfile中的ENTRYPOINT指令。

**shell**形式的ENTRYPOINT**不能**使用CMD参数，**也不能**通过命令行传递参数。 
如此做的缺点是：ENTRYPOINT将作为“/bin/sh -c”的子命令。此时，容器中的PID=1进程是/bin/sh，不是executable。当执行docker stop <container>的时候，SIGTERM信号会传递给/bin/sh，但是/bin/sh不会处理SIGTERM，忽略该信号。executable也就无法收到SIGTERM信号，从而executable不能“优雅”的结束。

只有最后一个ENTRYPOINT指令起作用。

## EXEC形式的 ENTRYPOINT
可以使用EXEC形式的ENTRYPOINT设置相对固定的命令和参数，然后使用任何形式的CMD设置相对容易变化的参数。

``` sh
FROM ubuntu
ENTRYPOINT ["top", "-b"]
CMD ["-c"]
``` 

运行这个容器，可以发现top是唯一的进程。

``` sh
$ docker run -it --rm --name test  top -H
top - 08:25:00 up  7:27,  0 users,  load average: 0.00, 0.01, 0.05
Threads:   1 total,   1 running,   0 sleeping,   0 stopped,   0 zombie
%Cpu(s):  0.1 us,  0.1 sy,  0.0 ni, 99.7 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
KiB Mem:   2056668 total,  1616832 used,   439836 free,    99352 buffers
KiB Swap:  1441840 total,        0 used,  1441840 free.  1324440 cached Mem

  PID USER      PR  NI    VIRT    RES    SHR S %CPU %MEM     TIME+ COMMAND
    1 root      20   0   19744   2336   2080 R  0.0  0.1   0:00.04 top
```

可以通过“docker exec”命令进一步检查：
```sh
$ docker exec -it test ps aux
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  2.6  0.1  19752  2352 ?        Ss+  08:24   0:00 top -b -H
root         7  0.0  0.1  15572  2164 ?        R+   08:25   0:00 ps aux
```

如此形势下，可以通过“docker stop”命令优雅的终止容器中的top进程。

EXEC形式的ENTRYPOINT不会启动shell，也就是说，一般的shell processing不会发生。典型的如$HOME不会被替换。如果一定要做替换，可以如下形式：
``` Dockerfile
ENTRYPOINT ["sh", "-c", "echo $HOME"]
```

## shell形式的ENTRYPOINT
可以为ENTRYPOINT指定一个简单的字符串，如此，字符串将作为命令在shell中执行，即：/bin/sh -c <COMMANDS>。

这种形式会执行变量的替换，比如$HOME。但是该形式不接受CMD参数，也不接受运行容器时的命令行参数。

### 没有exec前缀
如下形式将**不会接受**docker stop命令发送的SIGTERM信号。
``` Dockerfile
FROM ubuntu
ENTRYPOINT top -b
CMD --ignored-param1
```

因为此时，容器中的PID=1进程是/bin/sh，不是top。
```
$ docker run -it --name test top --ignored-param2
Mem: 1704184K used, 352484K free, 0K shrd, 0K buff, 140621524238337K cached
CPU:   9% usr   2% sys   0% nic  88% idle   0% io   0% irq   0% sirq
Load average: 0.01 0.02 0.05 2/101 7
  PID  PPID USER     STAT   VSZ %VSZ %CPU COMMAND
    1     0 root     S     3168   0%   0% /bin/sh -c top -b cmd cmd2
    7     1 root     R     3164   0%   0% top -b
```
当然是有办法改变的。

### exec前缀
在这种形势下，命令前添加**exec**：
``` Dockerfile
FROM ubuntu
ENTRYPOINT exec top -b
```
此时PID=1的进程是top。
``` sh
$ docker run -it --rm --name test top
Mem: 1704520K used, 352148K free, 0K shrd, 0K buff, 140368121167873K cached
CPU:   5% usr   0% sys   0% nic  94% idle   0% io   0% irq   0% sirq
Load average: 0.08 0.03 0.05 2/98 6
  PID  PPID USER     STAT   VSZ %VSZ %CPU COMMAND
    1     0 root     R     3164   0%   0% top -b
```
此时可以通过docker stop优雅的终止进程。

