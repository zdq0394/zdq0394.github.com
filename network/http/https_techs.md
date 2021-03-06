# HTTPS安全技术
## 安全技术要求
* 服务器认证（客户端知道它们是在与真正的而不是伪造的服务器通话
* 客户端认证（服务器知道它们是在与真正的而不是伪造的客户端通话
* 完整性 防篡改，客户端和服务器的数据不会被篡改
* 加密 防窃听，客户端和服务器的对话是私密的
* 效率 一个运行的足够快的算法，以便低端的客户端和服务器使用
* 普适性 基本上所有的客户端和服务器都支持这些协议
* 管理的可扩展性 任何地方的任何人都可以立即进行安全通信
* 适应性 能够支持当前最知名的安全方法
* 社会可行性 满足社会的政治文化需要

## 密码
密码是一套**编码方案**——一种特殊的报文编码方式和解码方式的结合体。加密之前的原始报文称为**明文**（plaintext或者cleartext），加密之后的编码报文称为**密文**（ciphertext）。
### 密钥
密码参数被成为**密钥**。不同的密钥产生不同的密码工作方式。
### 对称加密&非对称加密
对称密钥：编码和解码时使用相同的密钥。对称密钥加密算法：DES，Triple-DES，RC2和RC4。
非对称密钥：编码和解码时使用不同的密钥。非对称密钥加密算法：RSA。

HTTPS的通信过程中只在握手阶段使用了**非对称加密**，后面的通信过程均使用**对称加密**。

尽管非对称加密相比对称加密更加安全，但也存在两个明显缺点：
1. CPU计算资源消耗非常大。一次完全TLS握手，密钥交换时的非对称解密计算量占整个握手过程的90%以上。而**对称加密的计算量只相当于非对称加密的0.1%**，如果应用层数据也使用非对称加解密，性能开销太大，无法承受。
2. 非对称加密算法对**加密内容的长度有限制**，**不能超过公钥长度**。比如现在常用的公钥长度是2048位，意味着待加密内容不能超过256个字节。

所以公钥加密目前只能用来作密钥交换或者内容签名，不适合用来做应用层传输内容的加解密。
非对称密钥交换算法是整个HTTPS得以安全的基石，充分理解非对称密钥交换算法是理解HTTPS协议和功能的关键。

### 数字签名
通过公钥加密，私钥解密可以防止窃听。
通过私钥加密，公钥解密可以防止篡改。

数字签名是附加在报文上的特殊的加密校验和。

## 数字证书
数字证书的格式普遍采用的是**X.509V3**国际标准，一个标准的X.509数字证书包含以下一些内容：

* 证书的版本信息
* 证书的序列号，每个证书都有一个唯一的证书序列号
* 证书所使用的签名算法
* 证书的发行机构名称，命名规则一般采用X.500格式
* 证书的有效期，通用的证书一般采用UTC时间格式，它的计时范围为1950-2049
* 证书所有人的名称，命名规则一般采用X.500格式
* 证书所有人的公钥
* 证书发行者对证书的签名

证书以链的形式组织，上级标识该证书的签发机构，验证证书的时候也是顺着这个链层层验证的，只有所有证书都是受信的，整个验证结果才是可信的。

那么根证书是如何验证的呢？**根证书是自信任的**，在操作系统或者浏览其中都会默认一些**受信任的CA机构根证书**。

**除非对这个根证书有绝对的信任才可以加入信任列表中**，因为**根证书是有权签发子证书的**，如果根证书失信，那么对应的子证书的可信性就无从谈起，那么与使用相应证书的HTTPS网站通信的安全性就得不到保障了。

基于X.509证书的签名有好几种：包括Web服务器证书、客户端电子邮件证书、软件代码签名证书和证书颁发结构证书。

