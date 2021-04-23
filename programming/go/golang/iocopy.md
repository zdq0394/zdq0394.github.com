# GOLANG下载大文件性能比较
## 大文件下载


## 性能测试
[测试代码](https://github.com/zdq0394/try-in-go/tree/master/bigfiledown)
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