# Error loading shared library ld-linux-x86-64.so.2: No such file or directory
## 方法一
```sh
RUN apk update && apk add --no-cache libc6-compat
```
## 方法二
```sh
RUN apk update && apk add --no-cache libc6-compat
ln -s /lib/libc.musl-x86_64.so.1 /lib/ld-linux-x86-64.so.2
```

https://stackoverflow.com/questions/50288034/unsatisfiedlinkerror-tmp-snappy-1-1-4-libsnappyjava-so-error-loading-shared-li/51655643#51655643