# 一次进程卡死分析
## strace
```sh
strace -p PID
```
查看进程信息

## lsof
```sh
lsof -p PID
```
查看所有打开的fd。


## top
```sh
top -Hp PID
```

## pstree
```sh
pstree -p PID
```