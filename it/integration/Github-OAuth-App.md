# OAuth App集成
## 注册您的OAuth App
首先，需要将应用注册到github中。每个注册过的OAuth application会被分配一个唯一的Client ID及对应的Client Secret。

注册应用的时候需要填写一些信息。其中最重要的是**Authorization callback URL。当Github认证通过的时候将会调用该URL。

## 授权

1. 提供链接：
https://github.com/login/oauth/authorize?scope=user:email&client_id=Your-Client-ID将引导某个用户向client_id代表的应用授权：授权范围为user:email。

2. 用户输入用户名和密码后，授权通过会跳转到client_id代表的应用提供的callback URL。

3. 应用服务器在callback URL请求中，可以向https://github.com/login/oauth/access_token发送Post请求交换accesstoken。


## 参考链接
* https://developer.github.com/v3/guides/basics-of-authentication/