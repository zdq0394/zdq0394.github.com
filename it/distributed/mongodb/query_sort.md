# MongoDB排序
## 排序
在MongoDB中使用使用sort()方法对数据进行排序，sort()方法可以通过参数指定排序的字段，并使用1和-1来指定排序的方式：
* 1为升序排列
* -1是用于降序排列

```
>db.COLLECTION_NAME.find().sort({KEY:1})
```

```
>db.books.find({},{"title":1,_id:0}).sort({"likes":-1})
{ "title" : "PHP 教程" }
{ "title" : "Java 教程" }
{ "title" : "MongoDB 教程" }
>
```

## Limit
MongoDB中读取指定数量的数据记录。limit()方法接受一个数字参数，该参数指定从MongoDB中读取的记录条数。

```
>db.COLLECTION_NAME.find().limit(NUMBER)
```

## Skip
MongoDB使用skip()方法来跳过指定数量的数据，skip方法同样接受一个数字参数作为跳过的记录条数。

```
>db.COLLECTION_NAME.find().limit(NUMBER).skip(NUMBER)
```

**skip()方法默认参数为0**。

## 补充说明
skip和limit方法只适合小数据量分页，如果是百万级效率就会非常低，因为skip方法是一条条数据数过去的，建议使用where_limit。
