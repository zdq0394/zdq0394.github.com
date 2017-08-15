# Blank field in struct
在学习go语言过程中，经常看到类似的定义，开始非常疑惑，定义这样一个blank的空变量有什么用呢？
当然肯定是有用的。

    type User struct {
	    Name string
	    _    bool
    }

通过下面的代码可以发现，这样定义结构体，就强制只能通过**命名参数**的形式初始化结构体，而不能通过**位置参数**的形式初始化结构体。

    func NewUser() (user *User) {
	    //user = &User{"Jack", true} //1. cannot refer to blank field or method
	    user = &User{                //2. OK
		    Name: "Jack",
	    }
	    return
    }

通过命名参数而不是位置参数初始化结构体的好处是当结构体添加了字段，如果原来的API如果用不到这些字段，可以保持稳定。
