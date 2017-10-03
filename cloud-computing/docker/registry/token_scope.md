# Docker Registry Token Scope and Access
Registry使用的Tokens都有一定的限制：

* 哪些资源可以访问：what resources they may be used to access
* 哪里可以访问资源：where those resources may be accessed
* 哪些操作可以执行：what actions may be done on those resources

Tokens上下文中包含一个user，即token签发的对象。

## Scope Components
### Subject (Authenticated User)
Subject代表token签发的user，该token只对该user有效。使用access token进行的任何操作，都代表该user在操作。
Subject包含在JWT中的**sub**字段。
Refresh token应该仅仅限定一个subject，并仅可以给这个subject颁发access tokens。

### Audience (Resource Provider)
Audience代表资源提供者，资源提供者可以完成token中指定的操作。
与token中指定的audience不匹配的资源提供者不应该使用该token进行操作。
Audience包含在JWT中的**aud**字段中refre。
Refresh token应该仅仅限定给一个audience，并仅仅可以给这个audience签发access tokens。

### Resource Type
The resource type代表了一个资源的类型。资源类型是**资源提供者相关的**，但是必须能够被authorization server认知，这样才能决定是否授权Sub访问指定资源。

**RESOURCE CLASS**
Resource type或许具有resource class，进一步对resource name进行分类。Resource class不是必需的，并且是和resource type相关的。

**RESOURCE TYPES示例**

* repository：代表registry中的一个repository。默认repository type具有resource class——**image**。
* repository(plugin)：代表registry中的一个repository of plugins。
* registry：代表整个registry，管理和浏览整个registry的资源。

### Resource Name
Resource name代表资源提供者提供的一个资源的名字。一个资源可以通过resource name和resource type确定。
示例：Resource name是image tag的名字部分：比如**samalba/myapp**或者**hostname/samalba/myapp**。

### Resource Actions
Resource actions定义了token所允许的在指定资源上执行的操作。这些操作是类型相关的，正常情况下具有针对资源的**读操作**和**写操作**。比如针对repository：pull是读操作，push是写操作。

## Authorization Server Use
对Access token的请求参数中包含**scope**和**audience**字段，subject则可以从传入的credentials或者refresh token推导出。
当使用refresh token时，传入的audience必需和refresh token中定义的audience匹配。
Audience(resource provider)通过字段service提供。

* GET请求中，多个resource scopes通过多个scope字段提供。
* POST请求中仅包含一个scope字段：通过空格分开多个resource scopes。

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
一旦**resource provider**通过**JWT access token verification**验证了authenticity of the scope，**resource provider**必须确保scope满足请求。**Resource provider**应当匹配audience。Resource provider使用name或者URI来认证自身。

Resource provider必须确保请求访问的任何资源都有合适的访问权限。 Resource type和resource name必需都匹配，并且包含合适的action scope。

如过没有提供认证，resource provider返回WWW-AUTHENTICATE HTTP header和realm：authorization server，当前服务作为期望的audience identifying string，以及一个针对每个资源都有的一个scope字段。

## JWT Access Tokens
一个JWT access token一般仅包含一个subject，一个audience，却有多个resource scopes。
Subject和audience被放在标准的JWT字段**sub**和**aud**中。
Resource scope放置在**access**字段中。

## Refresh Tokens
Refresh token必须是针对一个subject和audience的。如果要进一步限制scope到指定的type、name和actions组合，则需要通过refresh token换取access token。
由于refresh token并没有为audience限定scope到具体的资源，使用refresh token要格外小心：只能仅用来和authorizaion server协商换取access token，禁止和resource provider直接协商通信。
