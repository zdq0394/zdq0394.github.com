# GOLANG下载大文件性能比较
## 大文件下载

大文件下载[参考](https://stackoverflow.com/questions/11692860/how-can-i-efficiently-download-a-large-file-using-go)

## 性能测试

[测试代码](https://github.com/zdq0394/try-in-go/tree/master/bigfiledown)

本测试在windows机器测试(8核16G)，server端使用go fileserver，运行在本地。

### 文件1G
| 方法 | 总时间 | 平均时间 |
| -----| ----- | ------ |
| io.Copy | 22.245 | 3.1778 |
| io.CopyBuffer(8K) | 27.0870 | 3.8696 |
| io.CopyBuffer(16K) | 21.0605 | 3.0086 |
| io.CopyBuffer(32K) | 21.2355 | 3.0336 |
| io.CopyBuffer(64K) | 20.8140 | 2.9734 |
| io.CopyBuffer(4M) | 39.6735 | 5.6676 |
| io.CopyBuffer(16M) | 89.8425 | 12.8346 |

### 文件5G
| 方法 | 总时间 | 平均时间 |
| -----| ----- | ------ |
| io.Copy | 226.6190 | 32.3741 |
| io.CopyBuffer(8K) | 237.2930 | 33.8990 |
| io.CopyBuffer(16K) | 238.0895 | 34.0128 |
| io.CopyBuffer(32K) | 248.6540 | 35.5220 |
| io.CopyBuffer(64K) | 226.6340 | 32.3763 |
| io.CopyBuffer(4M) | 279.0690 | 39.8670 |
| io.CopyBuffer(16M) | 681.0860 | 97.2980 |