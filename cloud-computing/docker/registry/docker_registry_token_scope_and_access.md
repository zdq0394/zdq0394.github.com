# Docker Registry Token Scope and Access
## Scope Components
### Subject (Authenticated User)
The subject代表一个user。该token只对该user有效，通过这个access token进行的任何操纵，都代表该user。Subject包含在JWT中的**sub**字段。A refresh token应该仅仅限定给一个subuject，并仅可以给这个subject颁发access tokens。
### Audience (Resource Provider)
The audience代表一个资源提供者：资源提供者可以执行token中指定的操作。和token中指定的audience不匹配的资源提供者不应该使用该token。 Audience包含在JWT中的**aud**字段中。 A refresh token应该仅仅限定给一个audience，并仅可以给这个audience办法access tokens。 
### Resource Type
The resource type代表了一个资源的类型。资源类型是资源提供者相关的，但是必须能够被authorization server认知。

* repository
* repository(plugin)
* registry
### Resource Name
The resource name代表某个资源提供者提供的一个资源的名字。一个资源可以通过name和type确定。典型的，比如一个repository的名字，不包括tag部分。
### Resource Actions
The resource actions定义了token允许的在指定资源上执行的操作。这些操作是类型相关的；一般情况下有针对资源的读操作和写操作。比如针对repository，pull是读操作，push是写操作。

## Authorization Server Use
每个access token请求都应该包含scope和audience字段，subject则可以从传入的credentials或者refresh token推导出。当使用refresh token时，传入的audience必需和refresh token中定义的audience匹配。The audience (resource provider)通过字段service提供。
GET请求中，多个resource scopes通过多个scope字段提供。POST请求中仅包含一个scope字段：通过空格分开多个resource scopes。

### Resource Scope Grammar

``` yaml
scope                   := resourcescope [ ' ' resourcescope ]*
resourcescope           := resourcetype  ":" resourcename  ":" action [ ',' action ]*
resourcetype            := resourcetypevalue [ '(' resourcetypevalue ')' ]
resourcetypevalue       := /[a-z0-9]+/
resourcename            := [ hostname '/' ] component [ '/' component ]*
hostname                := hostcomponent ['.' hostcomponent]* [':' port-number]
hostcomponent           := /([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9])/
port-number             := /[0-9]+/
action                  := /[a-z]*/
component               := alpha-numeric [ separator alpha-numeric ]*
alpha-numeric           := /[a-z0-9]+/
separator               := /[_.]|__|[-]*/
```

## Resource Provider Use
一旦resource provider通过JWT access token verification验证了authenticity of the scope through，resource provider必须确保scope满足请求。The resource provider应当匹配audience。 resource provider使用name或者URI来认证自身。

Resource provider必须确保请求访问的任何资源都有合适的访问权限。 Resource type和resource name必需都匹配，并且包含合适的action scope。

如过没有提供认证，resource provider返回WWW-AUTHENTICATE HTTP header和realm：authorization server，当前服务作为期望的audience identifying string，以及一个针对每个资源都有的一个scope字段。


## JWT Access Tokens
一个JWT access token一般仅包含一个subject，一个audience，却有多个resource scopes。subject和audience都在标准的JWT字段sub和aud中；resource scope放置在access字段中。

## Refresh Tokens
A refresh token必须是针对一个subject和audience的。进一步限制scope到指定的type、name和actions组合需要通过refresh token换取的access token定义。由于refresh token并没有为audience限定scope到具体的资源，使用refresh token和authrizaton server换取access token时要格外小心，并且禁止和resource provider协商通信。
