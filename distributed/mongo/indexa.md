# MongoDB高级索引
考虑以下文档集合（users）:

```
{
   "address": {
      "city": "Los Angeles",
      "state": "California",
      "pincode": "123"
   },
   "tags": [
      "music",
      "cricket",
      "blogs"
   ],
   "name": "Tom Benzamin"
}
```

## 索引数组字段
假设我们基于标签来检索用户，为此我们需要对集合中的数组tags建立索引。

在数组中创建索引，需要对数组中的每个字段依次建立索引。所以在我们为数组tags创建索引时，会为music、cricket、blogs三个值建立单独的索引。

使用以下命令创建数组索引：

```
>db.users.ensureIndex({"tags":1})
```
创建索引后，我们可以这样检索集合的tags字段：

```
>db.users.find({tags:"cricket"})
```

## 索引子文档字段
假设我们需要通过city、state、pincode字段来检索文档，由于这些字段是子文档的字段，所以我们需要对子文档建立索引。

为子文档的三个字段创建索引，命令如下：

```
>db.users.ensureIndex({"address.city":1,"address.state":1,"address.pincode":1})
```
一旦创建索引，我们可以使用子文档的字段来检索数据：

```
>db.users.find({"address.city":"Los Angeles"})   
```

记住查询表达式必须遵循指定的索引的顺序。所以上面创建的索引将支持以下查询：

```
>db.users.find({"address.city":"Los Angeles","address.state":"California"}) 
```
同样支持以下查询：

```
>db.users.find({"address.city":"LosAngeles","address.state":"California","address.pincode":"123"})
```