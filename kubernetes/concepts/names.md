# Names
Kubernetes REST API中的所有对象都有一个唯一的Name和UID。

对于用户提供的不唯一的属性，Kubernetes提供了labels和annotations。

## Names
一个由客户端提供的string字段，表示一个资源路径URL中的object，比如`/api/v1/pods/some-name`。

对于一种类型的对象（kind），在同一时间，只能有一个相同的名字。
当然，如果删除了一个对象之后，可以创建一个同名的对象。

惯例，name的长度不超过`253`个字符。可以包括小写字母、数字、`-`和`_`。

### UIDs
Kubernetes system生成的字符串，在Kubernetes Cluster的整个生命周期具有唯一性，可以用来区分同一实体的不同历史版本（historical occurrences）。
