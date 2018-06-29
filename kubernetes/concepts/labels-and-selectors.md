# Labels and Selectors
Labels是附加到objects比如pods上的key-values pairs。
和annotations不同，labels用来指出object的identifying属性。
Labels可以用来组织和筛选objects的子集。
Labels可以在创建时添加，也可以随后的任何时间添加和修改。

对于一个object来说，Label的key必须唯一。

```json
"labels": {
  "key1" : "value1",
  "key2" : "value2"
}
```

## Syntax and character set
Labels是key-value pairs。
合法的label key包括2部分：`an optional prefix`和`name`，以`/`分割。

**Name**
* 必需；
* 不超过63个字符；
* 开始字符和终结字符只能是字母或数字（[a-z0-9A-Z]）；
* 中间字符可以是：字母、数字、短杠（-）、下划线（_）和点（.）

**Prefix**
* 可选；
* DNS subdomain形式；
* 不超过253个字符；
* 以`/`结尾；
* `kubernetes.io/`是Kubernetes核心组件保留的前缀。

合法的label values：
* 不超过63个字符
* 可以空
* 开始字符和终结字符只能是字母或数字（[a-z0-9A-Z]）；
* 中间字符可以是：字母、数字、短杠（-）、下划线（_）和点（.）





