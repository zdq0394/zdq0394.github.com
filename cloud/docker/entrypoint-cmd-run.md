# ENTRYPOINT、CMD 和 RUN
## RUN
RUN和CMD/ENTRYPOINT的运行时机是不一样的：
* RUN运行在docker build阶段。
* CMD/ENTRYPOINT运行在docker run阶段。

## CMD和ENTRYPOINT
ENTRYPOINT和CMD的不同点在于执行docker run时参数传递方式，CMD指定的命令可以被docker run传递的命令覆盖。ENTRYPOINT不能。
### CMD
CMD提供的命令可以被docker run提供的命令覆盖。

比如：

	FROM alpine:3.4
	CMD ["echo", "hello-in-images-in-CMD"]

执行不同命令输出结果如下：

* 执行docker run [image-name]，输出：hello-in-images-in-CMD
* 执行docker run [image-name] echo "Hello-outbox"，输出：Hello-outbox
* 执行docker run [image-name] nocmd "Hello-outbox"，输出：exec: \"nocmd\": executable file not found in $PATH

### ENTRYPOINT
ENTRYPOINT提供的命令不会被docker run时的参数覆盖，而是将docker run传递的所有内容作为ENTRYPOINT的参数接在后面。
比如：

	FROM alpine:3.4
	ENTRYPOINT ["echo", "hello-in-images-ENTRYPOINT"]

执行不同命令输出结果如下：
* 执行docker run [image-name]，输出：hello-in-images-ENTRYPOINT
* 执行docker run [image-name] echo "Hello-outbox"，输出：hello-in-images-ENTRYPOINT echo Hello-outbox
* 执行docker run [image-name] nocmd "Hello-outbox"，输出：hello-in-images-ENTRYPOINT nocmd Hello-outbox

### CMD和ENTRYPOINT同时存在
CMD命令提供的一切都作为ENTRYPOINT的参数接在后面。
比如：

	FROM alpine:3.4
	CMD ["echo", "hello-in-images-in-CMD"]
	ENTRYPOINT ["echo", "hello-in-images-ENTRYPOINT"]

执行不同命令输出结果如下：

* 执行docker run [image-name]，输出：hello-in-images-ENTRYPOINT echo hello-in-images-in-CMD
* 执行docker run [image-name] echo "Hello-outbox"，输出：hello-in-images-ENTRYPOINT echo Hello-outbox
* 执行docker run [image-name] nocmd "Hello-outbox"，输出：hello-in-images-ENTRYPOINT nocmd Hello-outbox