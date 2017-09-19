# MongoDB数据库操作
## 创建数据库
## 语法
MongoDB创建数据库的语法格式如下：如果数据库不存在，则创建数据库，否则切换到指定数据库。

```
use DATABASE_NAME
```
数据库创建完之后，**show dbs**列表中看不到所创建的数据库，直到有**文档**插入到数据库的某个**集合**中。
## 示例

```
> use mydb
switched to db mydb
> db
mydb
> 
```

## 删除数据库
### 语法
MongoDB 删除数据库的语法格式如下：删除当前数据库，可以使用db命令查看当前数据库名。
### 示例

```
db.dropDatabase()
```

## 删除集合
### 语法
集合删除语法格式如下：

```
db.collection.drop()
```

### 示例

```
> use mydb
switched to db mydb
> show tables
events
> db.events.drop()
true
> show tables
> 
```
