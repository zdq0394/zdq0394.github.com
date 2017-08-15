package golang

type User struct {
	Name string
	_    bool
}

func NewUser() (user *User) {
	//user = &User{"Jack", true} //cannot refer to blank field or method
	user = &User{
		Name: "Jack",
	}
	return
}
