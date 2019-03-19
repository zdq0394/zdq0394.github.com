# MongoDB文档操作
文档的数据结构和JSON基本一样。所有存储在集合中的数据都是**BSON**格式。BSON是一种类json的一种**二进制**形式的存储格式,简称Binary JSON。
## 插入文档

MongoDB使用insert()或save()方法向集合中插入文档，语法如下：

```
db.COLLECTION_NAME.insert(document)
```

示例：

```
>db.books.insert({title: 'MongoDB 教程', 
    description: 'MongoDB 是一个 Nosql 数据库',
    by: '菜鸟教程',
    url: 'http://www.runoob.com',
    tags: ['mongodb', 'database', 'NoSQL'],
    likes: 100
})
```

以上实例中books是我们的集合名，如果该集合不在该数据库中，MongoDB会在**当前数据库**自动**创建该集合**并插入文档。

插入文档也可以使用**db.books.save(document)**命令：

1. 如果不指定_id字段save()方法类似于insert()方法
2. 如果指定_id字段，则会更新该_id的数据。

**3.2版本**后还有以下几种语法可用于插入文档:

1. db.collection.insertOne():向指定集合中插入一条文档数据
2. db.collection.insertMany():向指定集合中插入多条文档数据

## 更新文档
MongoDB使用update()和save()方法来更新集合中的文档。
### update()方法
语法：

```
db.collection.update(
   <query>,
   <update>,
   {
     upsert: <boolean>,
     multi: <boolean>,
     writeConcern: <document>
   }
)
```

参数说明：
* query：update的查询条件，类似sql update查询内where后面的。
* update：update的对象和一些更新的操作符（如$,$inc...）等，也可以理解为sql update查询内set后面的。
* upsert：可选，这个参数的意思是，如果不存在update的记录，是否插入objNew,true为插入，默认是false，不插入。
* multi：可选，mongodb默认是false，**只更新找到的第一条记录**，如果这个参数为true，就把按条件查出来多条记录全部更新。
* writeConcern：可选，抛出异常的级别。

示例：

```
>db.books.insert({
    title: 'MongoDB 教程', 
    description: 'MongoDB 是一个 Nosql 数据库',
    by: '菜鸟教程',
    url: 'http://www.runoob.com',
    tags: ['mongodb', 'database', 'NoSQL'],
    likes: 100
})

>db.books.update({'title':'MongoDB 教程'},{$set:{'title':'MongoDB'}})
WriteResult({ "nMatched" : 1, "nUpserted" : 0, "nModified" : 1 })   # 输出信息
> db.books.find().pretty()
{
        "_id" : ObjectId("56064f89ade2f21f36b03136"),
        "title" : "MongoDB",
        "description" : "MongoDB 是一个 Nosql 数据库",
        "by" : "菜鸟教程",
        "url" : "http://www.runoob.com",
        "tags" : [
                "mongodb",
                "database",
                "NoSQL"
        ],
        "likes" : 100
}
>
```

### save()方法
save()方法通过传入的文档来替换已有文档。语法格式如下：

```
db.collection.save(
   <document>,
   {
     writeConcern: <document>
   }
)
```

参数说明：
* document：文档。
* writeConcern：可选，抛出异常的级别。

```
>db.books.save({
    "_id" : ObjectId("56064f89ade2f21f36b03136"),
    "title" : "MongoDB",
    "description" : "MongoDB 是一个 Nosql 数据库",
    "by" : "Runoob",
    "url" : "http://www.runoob.com",
    "tags" : [
            "mongodb",
            "NoSQL"
    ],
    "likes" : 110
})
>db.books.find().pretty()
{
        "_id" : ObjectId("56064f89ade2f21f36b03136"),
        "title" : "MongoDB",
        "description" : "MongoDB 是一个 Nosql 数据库",
        "by" : "Runoob",
        "url" : "http://www.runoob.com",
        "tags" : [
                "mongodb",
                "NoSQL"
        ],
        "likes" : 110
}
> 
```
### 更多示例

1. 只更新第一条记录：db.books.update( { "count" : { $gt : 1 } } , { $set : { "test2" : "OK"} } );
2. 全部更新：db.books.update( { "count" : { $gt : 3 } } , { $set : { "test2" : "OK"} },false,true );
3. 只添加第一条：db.books.update( { "count" : { $gt : 4 } } , { $set : { "test5" : "OK"} },true,false );
4. 全部添加加进去：db.books.update( { "count" : { $gt : 5 } } , { $set : { "test5" : "OK"} },true,true );
5. 全部更新：db.books.update( { "count" : { $gt : 15 } } , { $inc : { "count" : 1} },false,true );
6. 只更新第一条记录：db.books.update( { "count" : { $gt : 10 } } , { $inc : { "count" : 1} },false,false );

## 删除文档
MongoDB remove()函数是用来移除集合中的数据。
语法如下：

```
db.collection.remove(
   <query>,
   {
     justOne: <boolean>,
     writeConcern: <document>
   }
)
```

参数说明：
* query：（可选）删除的文档的条件。
* justOne：（可选）如果设为 true 或 1，则只删除一个文档。
* writeConcern：可选）抛出异常的级别。

如果想删除所有数据：

```
db.books.remove({})
```