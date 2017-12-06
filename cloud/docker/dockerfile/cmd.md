# CMD
CMD有三种形式：
* CMD ["executable","param1","param2"]，exec形式（推荐方式）
* CMD ["param1","param2"]，作为[ENTRYPOINT](entrypoint.md)的默认参数
* CMD command param1 param2，shell形式

一个Dockerfile只能有一个CMD，如果有多个，只有最后一个起作用。

CMD的主要目的是为执行(executing)容器提供默认命令和参数。如果不包括命令，必须执行ENTRYPOINT。
如果CMD作为ENTRYPOINT的参数，那么CMD和ENTRYPOINT都必须是JSON Array形式的。

exec形式的CMD会当作JOSN数组解析，所以只能使用**双引号**（""），**不能**使用单引号('')。

exec形式不会调用shell命令，所以不会执行shell中的变量替换比如$HOME。当然，如果一定要执行替换，可以使用如下形式的exec：
```Dockerfile
CMD ["sh", "-c", "echo $HOME"]
```


