# CPU100%定位

## 1. 找到最耗CPU的进程

1. 执行top -c ，显示进程运行信息列表
2. 键入P (大写P)，进程按照CPU使用率排序

## 2. 找到最耗CPU的线程

1. top -Hp PID ，显示一个进程的线程运行信息列表
2. 键入P (大写P)，线程按照CPU使用率排序

## 3. 将线程PID转化为16进制

1. printf “%x\n” 10804

注意：因为堆栈里，线程id是用16进制表示的

## 4. 查看堆栈，找到线程
工具：pstack/jstack

比如：

jstack PID | grep 'ThreadID_in_x'

jstack 10765 | grep '0x2a34' -C5 --color