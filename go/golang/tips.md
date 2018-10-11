# Go Tips
## main package
* 命令源码文件：包含入口函数main的文件。
* 库源码文件：不包含入口函数main的文件。
* main package——包含命令源码文件的包——最好只包含命令源码文件，不要包含其他库源码文件——go build/install/run命令会出问题。
* main package——包含命令源码文件的包——可以包含多个命令源码文件，并且各个命令源码文件都可以单独build和run，但是不能在整个package层面build和run。