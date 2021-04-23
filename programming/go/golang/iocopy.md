# GOLANG下载大文件性能比较
## 大文件下载


## 性能测试
### 文件1G
| 方法 | 总时间 | 平均时间 |
| -----| ----- | ------ |
| io.Copy | 28.8949 | 5.7789 |
| io.CopyBuffer(8K) | 36.4869 | 7.2973 |
| io.CopyBuffer(16K) | 26.8660 | 5.3732 |
| io.CopyBuffer(32K) | 25.8059 | 5.1611 |
| io.CopyBuffer(64K) | 24.802 | 4.9604 |
| io.CopyBuffer(4M) | 45.52 | 9.1040 |
| io.CopyBuffer(16M) | 141.3555 | 28.2711 |
| io.CopyBuffer(64M) | 579.643 | 115.9286 |