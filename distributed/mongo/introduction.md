# MongoDB简介
## 什么是MongoDB
MongoDB是由C++语言编写的，是一个基于**分布式文件**存储的开源数据库系统。

在高负载的情况下，添加更多的节点，可以保证服务器性能。

MongoDB旨在为WEB应用提供可扩展的**高性能数据存储解决方案**。

MongoDB将数据存储为一个**文档**，数据结构由键值(key=>value)对组成。**MongoDB文档类似于JSON对象**。

字段值可以包含其他文档，数组及文档数组。

## 主要特点
* MongoDB的提供了一个**面向文档**存储，操作起来比较简单和容易。
* 可以在MongoDB记录中设置**任何属性的索引**来实现更快的排序。
* 可以通过本地或者网络创建数据镜像，这使得MongoDB有更强的扩展性。
* 如果负载的增加（需要更多的存储空间和更强的处理能力），可以分布在计算机网络中的其他节点上这就是所谓的**分片**。
* Mongo支持**丰富的查询表达式**。查询指令使用**JSON**形式的标记，可轻易查询文档中内嵌的对象及数组。
* MongoDB使用update()命令可以实现替换完成的文档（数据）或者一些指定的数据字段 。
* Mongodb中的map/reduce主要是用来对数据进行批量处理和聚合操作。
* Map和Reduce。Map函数调用emit(key,value)遍历集合中所有的记录，将key与value传给Reduce函数进行处理。
* Map函数和Reduce函数是使用Javascript编写的，并可以通过db.runCommand或mapreduce命令来执行MapReduce操作。
* GridFS是MongoDB中的一个内置功能，可以用于存放**大量小文件**。
* MongoDB允许在服务端执行脚本，可以用Javascript编写某个函数，直接在服务端执行，也可以把函数的定义存储在服务端，下次直接调用即可。
* MongoDB支持各种编程语言:RUBY，PYTHON，JAVA，C++，PHP，C#等多种语言。
* MongoDB安装简单。