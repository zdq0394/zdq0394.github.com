# Redis脚本
Redis脚本使用**Lua解释器**来执行脚本。 

Reids 2.6版本通过内嵌支持Lua环境。
执行脚本的常用命令为**EVAL**。
## 实例
```
127.0.0.1:6379> eval "return {KEYS[1],KEYS[2],ARGV[1],ARGV[2]}" 2 key1 key2 first second
1) "key1"
2) "key2"
3) "first"
4) "second"
```
## Redis脚本命令
* EVAL script numkeys key [key ...] arg [arg ...]：执行Lua脚本。
* EVALSHA sha1 numkeys key [key ...] arg [arg ...]：执行Lua脚本。
* SCRIPT EXISTS script [script ...]：查看指定的脚本是否已经被保存在缓存当中。
* SCRIPT FLUSH：从脚本缓存中移除所有脚本。
* SCRIPT KILL：杀死当前正在运行的Lua脚本。
* SCRIPT LOAD script：将脚本script添加到脚本缓存中，但并不立即执行这个脚本。