# Annotations
Kubernetes使用`annotations`可以附加任意的`non-identifying`元数据给objects。
Clients比如tools和libraries可以获取这些元数据。

## Attaching metadata to objects
附加元数据到objects上，可以通过`labels`和`annotations`两种方式。

**Labels**一般用来按照某种条件筛选objects或者objects的集合。

**Annotations**不是用来identify/select objects。 Annotation中的元数据可大可小，结构化或者非结构化，也可以包括Labels中不允许的字符。

Annotations和labels类似，也是key-values映射：
```json
"annotations": {
  "key1" : "value1",
  "key2" : "value2"
}
```

通常如下的信息被记录到annotations中：
* 声明式的配置层惯例的fields。
* Build，release或者image信息，比如时间戳，release IDs，git branch，PR numbers，image hashes，以及registry address。
* 指向logging、monitoring、analytics或者audit repositories的指针。
* 可以帮助调试的Client library或者工具的信息，比如name，version，和build information。
