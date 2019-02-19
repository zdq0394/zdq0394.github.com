# MongoDB概念
## 数据库
一个mongodb中可以建立多个数据库。

MongoDB的默认数据库为"db"，该数据库存储在data目录中。

MongoDB的单个实例可以容纳多个独立的数据库，每一个都有自己的集合和权限，不同的数据库也放置在不同的文件中。

"show dbs" 命令可以显示所有数据的列表：

```
$ ./mongo
MongoDB shell version: 3.0.6
connecting to: test
> show dbs
local  0.078GB
test   0.078GB
>
```

执行 "db" 命令可以显示当前数据库对象或集合：

```
$ ./mongo
MongoDB shell version: 3.0.6
connecting to: test
> db
test
> 

```

运行"use"命令，可以连接到一个指定的数据库：

```
> use local
switched to db local
> db
local
> 
```

有一些数据库名是保留的，可以直接访问这些有特殊作用的数据库:

* admin： 从权限的角度来看，这是"root"数据库。要是将一个用户添加到这个数据库，这个用户自动继承所有数据库的权限。一些特定的服务器端命令也只能从这个数据库运行，比如列出所有的数据库或者关闭服务器。
* local: 这个数据永远不会被复制，可以用来存储限于本地单台服务器的任意集合
* config: 当Mongo用于分片设置时，config数据库在内部使用，用于保存分片的相关信息。


## 文档
文档是一组**键值(key-value)对**(即**BSON**)。

MongoDB的文档不需要设置相同的字段，并且相同的字段不需要相同的数据类型，这与关系型数据库有很大的区别，也是 MongoDB 非常突出的特点。

一个简单的文档例子如下：

```
{"site":"www.github..com", "name":"github"}
```

需要注意的是：

* 文档中的键/值对是有序的。
* 文档中的值不仅可以是在双引号里面的字符串，还可以是其他几种数据类型（甚至可以是整个嵌入的文档)。
* MongoDB区分**类型**和**大小写**。
* MongoDB的文档不能有**重复的键**。
* 文档的键是**字符串**。除了少数例外情况，键可以使用任意UTF-8字符。

文档键命名规范：

* 键不能含有\0 (空字符)。这个字符用来表示键的结尾。
* .和$有特别的意义，只有在特定环境下才能使用。
* 以下划线"_"开头的键是保留的(不是严格要求的)。

## 集合
集合就是MongoDB文档组，类似于RDBMS中的表格。
集合存在于数据库中，**集合没有固定的结构**，这意味着对集合可以插入不同格式和类型的数据，但通常情况下我们插入集合的数据都会有一定的关联性。
比如，我们可以将以下不同数据结构的文档插入到集合中：

```
{"site":"www.mongodb.com"}
{"site":"www.google.com","name":"Google"}
{"site":"www.github.com.com","name":"github","num":5}
```
**当第一个文档插入时，集合就会被创建**。

合法的集合名:

* 集合名不能是空字符串""。
* 集合名不能含有\0字符（空字符)，这个字符表示集合名的结尾。
* 集合名不能以"system."开头，这是为系统集合保留的前缀。
* 用户创建的集合名字不能含有保留字符。有些驱动程序的确支持在集合名里面包含，这是因为某些系统生成的集合中包含该字符。除非你要访问这种系统创建的集合，否则千万不要在名字里出现$。　

**Capped collections**就是固定大小的collection。

它有很高的性能以及队列过期的特性(过期按照插入的顺序)。

Capped collections是高性能自动的维护对象的插入顺序。它非常适合类似记录日志的功能，和标准的collection不同，**必须要显式的创建一个capped collection**，指定一个collection的大小，单位是字节。**collection的数据存储空间值提前分配的**。

要注意的是指定的存储大小包含了数据库的头信息：

```
db.createCollection("mycoll", {capped:true, size:100000})
```

在capped collection中，能添加新的对象。能进行更新，然而，对象不会增加存储空间。如果要增加，更新就会失败。

数据库不允许进行删除。使用drop()方法删除collection所有的行。

注意: **删除之后，必须显式的重新创建这个collection**。

## 元数据
数据库的信息是存储在集合中。它们使用了系统的命名空间：**dbname.system.\***

* dbname.system.namespaces	列出所有名字空间。
* dbname.system.indexes	列出所有索引。
* dbname.system.profile	包含数据库概要(profile)信息。
* dbname.system.users	列出所有可访问数据库的用户。
* dbname.local.sources	包含复制对端（slave）的服务器信息和状态。

## MongoDB数据类型

* String：字符串。存储数据常用的数据类型。在MongoDB中，UTF-8编码的字符串才是合法的。
* Integer：整型数值。用于存储数值。根据所采用的服务器，可分为32位或64位。
* Boolean：布尔值。用于存储布尔值（真/假）。
* Double：双精度浮点值。用于存储浮点值。
* Min/Max keys：将一个值与BSON（二进制的JSON）元素的最低值和最高值相对比。
* Array：用于将数组或列表或多个值存储为一个键。
* Timestamp：时间戳。记录文档修改或添加的具体时间。
* Object：用于内嵌文档。
* Null：用于创建空值。
* Symbol：符号。该数据类型基本上等同于字符串类型，但不同的是，它一般用于采用特殊符号类型的语言。
* Date：日期时间。用UNIX时间格式来存储当前日期或时间。你可以指定自己的日期时间：创建Date对象，传入年月日信息。
* Object ID：对象 ID。用于创建文档的ID。
* Binary Data：二进制数据。用于存储二进制数据。
* Code：代码类型。用于在文档中存储JavaScript代码。
* Regular expression：正则表达式类型。用于存储正则表达式。

