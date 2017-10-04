# Token Authentication实现
## Docker Registry v2 Bearer token specification
本文描述Registry v2 authentication schema的docker/distribution实现。
尤其是，本文描述了JSON Web Token schema——docker/distribution按照该schema使用client-opaque Bearer token。
Bearer token是由authentication service签发，registry使用。

## Getting a Bearer Token
例如，客户端发起一个HTTP GET请求：

```
https://auth.docker.io/token?service=registry.docker.io&scope=repository:samalba/my-app:pull,push
```
Token server应该首先使用请求中的**authentication credentials**认证client。截止到Docker 1.8，Docker Engine中的registry client仅仅支持**Basic Authentication**。
如果认证失败，token server应返回401 Unauthorized响应：credentials不合法。

Token server是否需要authentication取决于访问控制服务器（access control provider）。有些请求需要认证才能决定访问权（比如pushing或者pulling一个私有的repository）有些不需要（pulling一个公共的repository）。

认证client之后（如果没有认证通过，则client就是一个anonymous client），token服务器必须随后查询访问控制列表ACL（access control list）决定客户端是否有权访问请求的scope。

在本例子中，如果我已经认证为jlhawn，token服务器将决定我对repository samalba/my-app的访问权限。

当确定了客户端对的对scope参数中的资源的访问权限之后，token server取两者的交集（请求的scope和授权的scope）。如果客户端仅被授权部分scope，不应该认为是错误。

Token server将构造一个JSON Web Token返回。JSON Web Token包含3个主要部分：

### Headers
JSON Web Token的header是一个标准的JOSE header。

* typ：JWT
* alg：signing algorithm used to produce the signature
* kid：representing the ID of the key which was used to sign the token

字段kid具有和libtrust fingerprint兼容的格式。这样格式的字段生成需要3步：

1. Take the DER encoded public key which the JWT token was signed against。
2. Create a SHA256 hash out of it and truncate to 240bits。
3. plit the result into 12 base32 encoded groups with : as delimiter。

示例：

```
{
    "typ": "JWT",
    "alg": "ES256",
    "kid": "PYYO:TEWU:V7JH:26JV:AQTZ:LJC3:SXVJ:XGHA:34F2:2LAQ:ZRMK:Z7Q6"
}
```

### Claim Set
Claim Set是一个JSON struct：包含注册的标准的claim name：

* iss (Issuer): token的签发者，一般是authorization server的fqdn。
* sub (Subject): token的对象主体user，client的name或者id。如果client没通过认证，该字段为空（`""`）。
* aud (Audience): token的对象资源服务，资源服务的name或者id。
* exp (Expiration): token的有效期终止时间。
* nbf (Not Before): token的有效期起始时间。
* iat (Issued At): Authorization server产生token的时间。
* jti (JWT ID): token的唯一标识。

Claim Set也会包含一个私有的唯一的claim name：

**access**: An array of access entry objects with the following fields:

* type: The type of resource hosted by the service.
* name: The name of the resource of the given type hosted by the service.
* actions: An array of strings which give the actions authorized on this resource.

示例：

```
{
    "iss": "auth.docker.com",
    "sub": "jlhawn",
    "aud": "registry.docker.com",
    "exp": 1415387315,
    "nbf": 1415387015,
    "iat": 1415387015,
    "jti": "tYJCO1c6cnyy7kAn0c7rKPgbV1H1bFws",
    "access": [
        {
            "type": "repository",
            "name": "samalba/my-app",
            "actions": [
                "pull",
                "push"
            ]
        }
    ]
}
```

### Signature
Authorization server产生一个没有任何多余空格的JOSE header和Claim Set：

```
{"typ":"JWT","alg":"ES256","kid":"PYYO:TEWU:V7JH:26JV:AQTZ:LJC3:SXVJ:XGHA:34F2:2LAQ:ZRMK:Z7Q6"}
```
```
{"iss":"auth.docker.com","sub":"jlhawn","aud":"registry.docker.com","exp":1415387315,"nbf":1415387015,"iat":1415387015,"jti":"tYJCO1c6cnyy7kAn0c7rKPgbV1H1bFws","access":[{"type":"repository","name":"samalba/my-app","actions":["push","pull"]}]}
```

JOSE header and Claim Set的utf-8形式然后使用url-safe base64编码：

```
eyJ0eXAiOiJKV1QiLCJhbGciOiJFUzI1NiIsImtpZCI6IlBZWU86VEVXVTpWN0pIOjI2SlY6QVFUWjpMSkMzOlNYVko6WEdIQTozNEYyOjJMQVE6WlJNSzpaN1E2In0
```
```
eyJpc3MiOiJhdXRoLmRvY2tlci5jb20iLCJzdWIiOiJqbGhhd24iLCJhdWQiOiJyZWdpc3RyeS5kb2NrZXIuY29tIiwiZXhwIjoxNDE1Mzg3MzE1LCJuYmYiOjE0MTUzODcwMTUsImlhdCI6MTQxNTM4NzAxNSwianRpIjoidFlKQ08xYzZjbnl5N2tBbjBjN3JLUGdiVjFIMWJGd3MiLCJhY2Nlc3MiOlt7InR5cGUiOiJyZXBvc2l0b3J5IiwibmFtZSI6InNhbWFsYmEvbXktYXBwIiwiYWN0aW9ucyI6WyJwdXNoIl19XX0
```
两部分用‘.’连接：

```
eyJ0eXAiOiJKV1QiLCJhbGciOiJFUzI1NiIsImtpZCI6IlBZWU86VEVXVTpWN0pIOjI2SlY6QVFUWjpMSkMzOlNYVko6WEdIQTozNEYyOjJMQVE6WlJNSzpaN1E2In0.eyJpc3MiOiJhdXRoLmRvY2tlci5jb20iLCJzdWIiOiJqbGhhd24iLCJhdWQiOiJyZWdpc3RyeS5kb2NrZXIuY29tIiwiZXhwIjoxNDE1Mzg3MzE1LCJuYmYiOjE0MTUzODcwMTUsImlhdCI6MTQxNTM4NzAxNSwianRpIjoidFlKQ08xYzZjbnl5N2tBbjBjN3JLUGdiVjFIMWJGd3MiLCJhY2Nlc3MiOlt7InR5cGUiOiJyZXBvc2l0b3J5IiwibmFtZSI6InNhbWFsYmEvbXktYXBwIiwiYWN0aW9ucyI6WyJwdXNoIl19XX0
```
然后将该字符串作为ES256 signature algorithm签名算法的payload。

示例：

```
{
    "kty": "EC",
    "crv": "P-256",
    "kid": "PYYO:TEWU:V7JH:26JV:AQTZ:LJC3:SXVJ:XGHA:34F2:2LAQ:ZRMK:Z7Q6",
    "d": "R7OnbfMaD5J2jl7GeE8ESo7CnHSBm_1N2k9IXYFrKJA",
    "x": "m7zUpx3b-zmVE5cymSs64POG9QcyEpJaYCD82-549_Q",
    "y": "dU3biz8sZ_8GPB-odm8Wxz3lNDr1xcAQQPQaOcr1fmc"
}
```

上述payload产生的signature：

```
QhflHPfbd6eVF4lM9bwYpFZIV0PfikbyXuLx959ykRTBpe3CYnzs6YBK8FToVb5R47920PVLrh8zuLzdCr9t3w
```
将所有部分连接起来，产生JWT：

```
eyJ0eXAiOiJKV1QiLCJhbGciOiJFUzI1NiIsImtpZCI6IlBZWU86VEVXVTpWN0pIOjI2SlY6QVFUWjpMSkMzOlNYVko6WEdIQTozNEYyOjJMQVE6WlJNSzpaN1E2In0.eyJpc3MiOiJhdXRoLmRvY2tlci5jb20iLCJzdWIiOiJqbGhhd24iLCJhdWQiOiJyZWdpc3RyeS5kb2NrZXIuY29tIiwiZXhwIjoxNDE1Mzg3MzE1LCJuYmYiOjE0MTUzODcwMTUsImlhdCI6MTQxNTM4NzAxNSwianRpIjoidFlKQ08xYzZjbnl5N2tBbjBjN3JLUGdiVjFIMWJGd3MiLCJhY2Nlc3MiOlt7InR5cGUiOiJyZXBvc2l0b3J5IiwibmFtZSI6InNhbWFsYmEvbXktYXBwIiwiYWN0aW9ucyI6WyJwdXNoIl19XX0.QhflHPfbd6eVF4lM9bwYpFZIV0PfikbyXuLx959ykRTBpe3CYnzs6YBK8FToVb5R47920PVLrh8zuLzdCr9t3w
```

产生的JWT放在HTTP response中返回给客户端：

```
HTTP/1.1 200 OK
Content-Type: application/json

{"token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJFUzI1NiIsImtpZCI6IlBZWU86VEVXVTpWN0pIOjI2SlY6QVFUWjpMSkMzOlNYVko6WEdIQTozNEYyOjJMQVE6WlJNSzpaN1E2In0.eyJpc3MiOiJhdXRoLmRvY2tlci5jb20iLCJzdWIiOiJqbGhhd24iLCJhdWQiOiJyZWdpc3RyeS5kb2NrZXIuY29tIiwiZXhwIjoxNDE1Mzg3MzE1LCJuYmYiOjE0MTUzODcwMTUsImlhdCI6MTQxNTM4NzAxNSwianRpIjoidFlKQ08xYzZjbnl5N2tBbjBjN3JLUGdiVjFIMWJGd3MiLCJhY2Nlc3MiOlt7InR5cGUiOiJyZXBvc2l0b3J5IiwibmFtZSI6InNhbWFsYmEvbXktYXBwIiwiYWN0aW9ucyI6WyJwdXNoIl19XX0.QhflHPfbd6eVF4lM9bwYpFZIV0PfikbyXuLx959ykRTBpe3CYnzs6YBK8FToVb5R47920PVLrh8zuLzdCr9t3w"}

```

## 使用token
客户端获取client之后，就将token放在HTTP请求的Authorization头中，再次请求registry：

```
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJFUzI1NiIsImtpZCI6IkJWM0Q6MkFWWjpVQjVaOktJQVA6SU5QTDo1RU42Ok40SjQ6Nk1XTzpEUktFOkJWUUs6M0ZKTDpQT1RMIn0.eyJpc3MiOiJhdXRoLmRvY2tlci5jb20iLCJzdWIiOiJCQ0NZOk9VNlo6UUVKNTpXTjJDOjJBVkM6WTdZRDpBM0xZOjQ1VVc6NE9HRDpLQUxMOkNOSjU6NUlVTCIsImF1ZCI6InJlZ2lzdHJ5LmRvY2tlci5jb20iLCJleHAiOjE0MTUzODczMTUsIm5iZiI6MTQxNTM4NzAxNSwiaWF0IjoxNDE1Mzg3MDE1LCJqdGkiOiJ0WUpDTzFjNmNueXk3a0FuMGM3cktQZ2JWMUgxYkZ3cyIsInNjb3BlIjoiamxoYXduOnJlcG9zaXRvcnk6c2FtYWxiYS9teS1hcHA6cHVzaCxwdWxsIGpsaGF3bjpuYW1lc3BhY2U6c2FtYWxiYTpwdWxsIn0.Y3zZSwaZPqy4y9oRBVRImZyv3m_S9XDHF1tWwN7mL52C_IiA73SJkWVNsvNqpJIn5h7A2F8biv_S2ppQ1lgkbw
```

## 验证token
Registry现在需要验证token：

* 确保issuer (iss claim)是它信任的authority。
* 确保registry就是claim中的audience (aud claim)。
* 确保当前事件在nbf和exp之间。
* 如果token是一次性使用的，确保JWT ID以前没有使用过。
* 检验access中指定的资源和动作。
* 验证token的签名是否有效。


如果其中的一个条件不满足，registry将返回403 Forbidden影响指出token是不合法的。

该流程中，registry从不回调authorization server。Registry只需要authorization server的公钥来验证token的签名是否有效。