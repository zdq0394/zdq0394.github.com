# MongoDB文档查询
MongoDB查询文档使用find()方法。find()方法以**非结构化**的方式来显示所有文档。

```
db.collection.find(query, projection)
```
* query：可选，使用查询操作符指定查询条件。
* projection：可选，使用投影操作符指定返回的键。查询时返回文档中所有键值，只需省略该参数即可（默认省略）。

pretty()方法以格式化的方式来显示所有文档。**db.col.find().pretty()**返回的结果更具有**可读性**。

除了find()方法之外，还有一个**findOne()**方法，它只返回一个文档。

## MongoDB与RDBMS Where语句比较
* 等于        {<key>:<value>}	         db.col.find({"by":"菜鸟教程"}).pretty()	   where by = '菜鸟教程'
* 小于        {<key>:{$lt:<value>}}	 db.col.find({"likes":{$lt:50}}).pretty()	  where likes < 50
* 小于或等于   {<key>:{$lte:<value>}}   db.col.find({"likes":{$lte:50}}).pretty()	where likes <= 50
* 大于	    {<key>:{$gt:<value>}}	 db.col.find({"likes":{$gt:50}}).pretty()	  where likes > 50
* 大于或等于	  {<key>:{$gte:<value>}}   db.col.find({"likes":{$gte:50}}).pretty()	where likes >= 50
* 不等于      {<key>:{$ne:<value>}}    db.col.find({"likes":{$ne:50}}).pretty()	 where likes != 50

## MongoDB AND/OR
MongoDB的find()方法可以传入多个键(key)，每个键(key)以逗号隔开，及常规SQL的AND条件。

### AND
```
>db.books.find({key1:value1, key2:value2}).pretty()
```
### OR
```
>db.books.find(
   {
      $or: [
         {key1: value1}, {key2:value2}
      ]
   }
).pretty()

```
### AND/OR
```
>db.col.find({"likes": {$gt:50}, $or: [{"by": "菜鸟教程"},{"title": "MongoDB 教程"}]}).pretty()
```

## 条件操作符
$gt：greater than：  >
$gte：gt equal：  >=
$lt：less than：  <
$lte：lt equal：  <=
$ne：not equal：  !=
$eq：equal：  =

使用方式：
```
{"likes" : {$gt : 100}}
{likes : {$gte : 100}}
{likes : {$lt : 150}}
{likes : {$lte : 150}}
{likes : {$lt :200, $gt : 100}}
```