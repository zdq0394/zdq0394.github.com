# govendor
## govendor简介
自1.5版本开始引入govendor工具，将项目依赖的外部包放到项目下的vendor目录下，并通过vendor.json文件来记录依赖包的版本，方便用户使用相对稳定的依赖。

对于govendor来说，主要存在三种位置的包：
* 项目自身的包组织为本地（local）包
* 传统的存放在$GOPATH下的依赖包为外部（external）依赖包
* 被govendor管理的放在vendor目录下的依赖包则为vendor包
## 包的类型
* +local：(l) packages in your project
* +external：(e) referenced packages in GOPATH but not in current project
* +vendor：(v) packages in the vendor folder
* +std：(s) packages in the standard library
* +excluded：(x) external packages explicitly excluded from vendoring
* +unused：(u) packages in the vendor folder, but unused
* +missing：  (m) referenced packages but not found
* +program：(p) package is a main package
* +outside  +external +missing
* +all      +all packages
## govendor命令
govendor命令格式为：govendor COMMAND。
命令：
* init：初始化vendor目录
* list：列出所有的依赖包
* add：添加包到vendor目录，如govendor add +external添加所有外部包到vendor目录
* add PKG_PATH：添加指定的依赖包到vendor目录
* update：从$GOPATH更新依赖包到vendor目录
* remove：从vendor管理中删除依赖
* status：列出所有缺失、过期和修改过的包
* fetch：添加或更新包到本地vendor目录
* sync：本地存在vendor.json时候拉去依赖包，匹配所记录的版本
* get：类似go get，拉取依赖包到vendor目录

## 简单示例

**设置工程**
cd "my project in GOPATH"
govendor init

**加入存在的GOPATH文件到vendor**
govendor add +external

**查看vendor列表**
govendor list

**Look at what is using a package**
govendor list -v fmt

**指明获取的版本**
govendor fetch golang.org/x/net/context@a4bbce9fcae005b22ae5443f6af064d80a6f5a55
govendor fetch golang.org/x/net/context@v1   # Get latest v1.*.* tag or branch.
govendor fetch golang.org/x/net/context@=v1  # Get the tag or branch named "v1".

**更新**
govendor fetch golang.org/x/net/context

**格式化**
govendor fmt +local

**构建**
govendor install +local

**测试**
govendor test +local

