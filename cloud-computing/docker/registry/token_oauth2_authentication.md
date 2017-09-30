OAuth2 Token Authentication

## Docker Registry v2 authentication using OAuth2

This document describes support for the OAuth2 protocol within the authorization server. **RFC6749** should be used as a reference for the protocol and HTTP endpoints described here.

Note: Not all token servers implement oauth2. If the request to the endpoint returns 404 using the HTTP POST method, refer to Token Documentation for using the HTTP GET method supported by all token servers.

## Refresh token format
对客户端来说，**refresh token**的格式是完全透明（opaque）的。**refresh token**的格式由authorization server决定。The authorization should ensure the token is sufficiently long and is responsible for storing any information about long-lived tokens which may be needed for revoking. 包含在token中的任何信息都不应该被客户端提取和展示。

## Getting a token

``` http
POST /token
```
**HEADERS**

Content-Type: application/x-www-form-urlencoded

**POST PARAMETERS**

***grant_type*** 
(REQUIRED) Type of grant used to get token。
* password：获取refresh token，需要同时传递参数username和password。
* refresh_token： 获取access token，需要同时传递参数refresh_token。
***service*** 
(REQUIRED) The name of the service which hosts the resource to get access for. Refresh tokens will only be good for getting tokens for this service.
***client_id*** 
(REQUIRED) String identifying the client. This client_id does not need to be registered with the authorization server but should be set to a meaningful value in order to allow auditing keys created by unregistered clients. 

Accepted syntax is defined in [RFC6749 Appendix A.1](https://tools.ietf.org/html/rfc6749#appendix-A.1)

***access_type*** 
(OPTIONAL) Access which is being requested. If "offline" is provided then a refresh token will be returned. The default is "online" only returning short lived access token. If the grant type is "refresh_token" this will only return the same refresh token and not a new one.

***scope*** 
(OPTIONAL) The resource in question, formatted as one of the space-delimited entries from the scope parameters from the WWW-Authenticate header shown above. This query parameter should only be specified once but may contain multiple scopes using the scope list format defined in the scope grammar. If multiple scope is provided from WWW-Authenticate header the scopes should first be converted to a scope list before requesting the token. The above example would be specified as: scope=repository:samalba/my-app:push. When requesting a refresh token the scopes may be empty since the refresh token will not be limited by this scope, only the provided short lived access token will have the scope limitation.

***refresh_token*** 
(OPTIONAL) The refresh token to use for authentication when grant type "refresh_token" is used.
***username*** ***password***
(OPTIONAL) The username／password to use for authentication when grant type "password" is used.


**RESPONSE FIELDS**

***access_token*** 
(REQUIRED) An opaque **Bearer token** that clients should supply to subsequent requests in the Authorization header. This token should not be attempted to be parsed or understood by the client but treated as opaque string.

***scope***
(REQUIRED) The scope granted inside the access token. This may be the same scope as requested or a subset. This requirement is stronger than specified in [RFC6749 Section 4.2.2](https://tools.ietf.org/html/rfc6749#section-4.2.2) by strictly requiring the scope in the return value.

***expires_in***
(REQUIRED) The duration in seconds since the token was issued that it will remain valid. When omitted, this defaults to 60 seconds. For compatibility with older clients, a token should never be returned with less than 60 seconds to live.

***issued_at***
(Optional) The RFC3339-serialized UTC standard time at which a given token was issued. If issued_at is omitted, the expiration is from when the token exchange completed.

***refresh_token***
(Optional) Token which can be used to get additional access tokens for the same subject with different scopes. This token should be kept secure by the client and only sent to the authorization server which issues bearer tokens. This field will only be set when `access_type=offline` is provided in the request.

## EXAMPLE GETTING REFRESH TOKEN
``` http
POST /token HTTP/1.1
Host: auth.docker.io
Content-Type: application/x-www-form-urlencoded

grant_type=password&username=johndoe&password=A3ddj3w&service=hub.docker.io&client_id=dockerengine&access_type=offline

HTTP/1.1 200 OK
Content-Type: application/json

{"refresh_token":"kas9Da81Dfa8","access_token":"eyJhbGciOiJFUzI1NiIsInR5","expires_in":900,"scope":""}
```

## EXAMPLE REFRESHING AN ACCESS TOKEN
```
POST /token HTTP/1.1
Host: auth.docker.io
Content-Type: application/x-www-form-urlencoded

grant_type=refresh_token&refresh_token=kas9Da81Dfa8&service=registry-1.docker.io&client_id=dockerengine&scope=repository:samalba/my-app:pull,push

HTTP/1.1 200 OK
Content-Type: application/json

{"refresh_token":"kas9Da81Dfa8","access_token":"eyJhbGciOiJFUzI1NiIsInR5":"expires_in":900,"scope":"repository:samalba/my-app:pull,repository:samalba/my-app:push"}
```

