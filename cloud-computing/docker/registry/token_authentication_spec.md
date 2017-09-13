# Docker Registry v2 Authentication
Docker Registry v2 Authentication 流程如下：
![](pics/v2_registry_auth.png)

1. 准备往registry进行push/pull操作
2. If the registry requires authorization it will return a 401 Unauthorized HTTP response with information on how to authenticate.
3. The registry client makes a request to the authorization service for a Bearer token.
4. The authorization service returns an opaque Bearer token representing the client’s authorized access.
5. The client retries the original request with the Bearer token embedded in the request’s Authorization header.
6. The Registry authorizes the client by validating the Bearer token and the claim set embedded within it and begins the push/pull session as usual.