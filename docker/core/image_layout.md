# 镜像及其layer存储分析
本文以一个镜像为例来分析镜像如何存储在磁盘上的。
## 环境定义
* Centos 7.4; 内核版本4.17.3-1.el7.elrepo.x86_64
* Docker Version: 1.13.1
* Storage Driver: overlay2
## 镜像
首先，若无特殊指定，docker daemon的使用目录`/var/lib/docker`存放资源。

镜像保存在`/var/lib/docker/image/<STORAGE-DRIVER>`下。在本系统中，则保存在`/var/lib/docker/image/overlay2`目录下。该目录下有3个文件夹和一个json文件（repositories.json）：
* repositories.json：所有镜像的索引。
* imagedb：镜像的描述信息
* layerdb：镜像的层信息
* distribution：这个与docker registry相关，主要描述diff-id和digest之间的映射关系。

### repositories.json文件
文件如下描述了本机所有镜像。
```json
# cat repositories.json | python -mjson.tool
{
    "Repositories": {
        "nginx": {
            "nginx:latest": "sha256:ae513a47849c895a155ddfb868d6ba247f60240ec8495482eca74c4a2c13a881"
        }
    }
}
```
```sh
[root@dqvm overlay2]# docker images
REPOSITORY  TAG     IMAGE ID        CREATED             SIZE
nginx       latest  ae513a47849c    6 months ago        109 MB
```
可以看到在repository.json中记录了镜像tag与image-id（image id是镜像的config文件内容的sha256哈希）之间的映射关系。

### imagedb
进入imagedb，发现下面有2个子目录(content和metadata)。先掠过metadata不谈，直接进入content/sha256下面；下面存放的是各个镜像的config文件，文件名就是各个config文件内容的sha256哈希。
比如，上面提到的nginx镜像，ae513a47849c895a155ddfb868d6ba247f60240ec8495482eca74c4a2c13a881，文件内容的sha256sum刚好也是ae513a47849c895a155ddfb868d6ba247f60240ec8495482eca74c4a2c13a881。
```sh
# cat ae513a47849c895a155ddfb868d6ba247f60240ec8495482eca74c4a2c13a881 | sha256sum
ae513a47849c895a155ddfb868d6ba247f60240ec8495482eca74c4a2c13a881  -
```

查看该文件的内容（忽略了除rootfs之外的信息）：
```json
# cat ae513a47849c895a155ddfb868d6ba247f60240ec8495482eca74c4a2c13a881 | python -mjson.tool
{
    "architecture": "amd64",
    ...
    "rootfs": {
        "diff_ids": [
            "sha256:d626a8ad97a1f9c1f2c4db3814751ada64f60aed927764a3f994fcd88363b659",
            "sha256:82b81d779f8352b20e52295afc6d0eab7e61c0ec7af96d85b8cda7800285d97d",
            "sha256:7ab428981537aa7d0c79bc1acbf208c71e57d9678f7deca4267cc03fba26b9c8"
        ],
        "type": "layers"
    }
}

```

由此可以看出该镜像包括3个layer，自底向上分别是：
* d626a8ad97a1f9c1f2c4db3814751ada64f60aed927764a3f994fcd88363b659
* 82b81d779f8352b20e52295afc6d0eab7e61c0ec7af96d85b8cda7800285d97d
* 7ab428981537aa7d0c79bc1acbf208c71e57d9678f7deca4267cc03fba26b9c8
那这三个layer是如何存放的呢？继续
### layerdb
这里牵涉到一个chain-id的概念，这里只讲计算方法：
最底层的chain-id和layer的diff-id是相同的。
digest(n) = digest(chain-id(n-1)+" "+dif-id(n))

3个layer对应的chain-id分别如下：
* d626a8ad97a1f9c1f2c4db3814751ada64f60aed927764a3f994fcd88363b659
* f246685cc80c2faa655ba1ec9f0a35d44e52b6f83863dc16f46c5bca149bfefc
* 160a8bd939a9421818f499ba4fbfaca3dd5c86ad7a6b97b6889149fd39bd91dd
计算命令如下：
```sh
# echo -n "sha256:d626a8ad97a1f9c1f2c4db3814751ada64f60aed927764a3f994fcd88363b659 sha256:82b81d779f8352b20e52295afc6d0eab7e61c0ec7af96d85b8cda7800285d97d" | sha256sum 
f246685cc80c2faa655ba1ec9f0a35d44e52b6f83863dc16f46c5bca149bfefc  -

# echo -n "sha256:f246685cc80c2faa655ba1ec9f0a35d44e52b6f83863dc16f46c5bca149bfefc sha256:7ab428981537aa7d0c79bc1acbf208c71e57d9678f7deca4267cc03fba26b9c8" | sha256sum 
160a8bd939a9421818f499ba4fbfaca3dd5c86ad7a6b97b6889149fd39bd91dd  -
```
layerdb目录下有3个文件夹，现只关注sha256，在该文件夹包括了所有的layer，文件夹的命名都是对应的层的chain-id。
```sh
# ls
mounts  sha256  tmp
```
先看最底层的layer`d626a8ad97a1f9c1f2c4db3814751ada64f60aed927764a3f994fcd88363b659`，其chainID也是`d626a8ad97a1f9c1f2c4db3814751ada64f60aed927764a3f994fcd88363b659`，
``` sh
[root@localhost d626a8ad97a1f9c1f2c4db3814751ada64f60aed927764a3f994fcd88363b659]# ls
cache-id  diff  size  tar-split.json.gz
[root@localhost d626a8ad97a1f9c1f2c4db3814751ada64f60aed927764a3f994fcd88363b659]# cat diff 
sha256:d626a8ad97a1f9c1f2c4db3814751ada64f60aed927764a3f994fcd88363b659
[root@localhost d626a8ad97a1f9c1f2c4db3814751ada64f60aed927764a3f994fcd88363b659]# cat cache-id 
ef8fb5e2c72a523c58c247aeb9bbb36d691ce7720145ff378ebf3714fa8d3e7f
```
其文件下包含了4文件（夹）：其中diff文件包含了其对应的layer的dif-id。

cache-id另有用处，指出了该层内容在本系统中storage driver（overlay2）中的内容位置。

然后进入第二个layer，chainID是`f246685cc80c2faa655ba1ec9f0a35d44e52b6f83863dc16f46c5bca149bfefc`。
与最底层不同，该文件夹多了一个名为parent的文件，内容为下层layer的chain-id；
同样diff内容为该层的diff-id。
```sh
[root@localhost f246685cc80c2faa655ba1ec9f0a35d44e52b6f83863dc16f46c5bca149bfefc]# ls
cache-id  diff  parent  size  tar-split.json.gz
[root@localhost f246685cc80c2faa655ba1ec9f0a35d44e52b6f83863dc16f46c5bca149bfefc]# cat parent 
sha256:d626a8ad97a1f9c1f2c4db3814751ada64f60aed927764a3f994fcd88363b659
[root@localhost f246685cc80c2faa655ba1ec9f0a35d44e52b6f83863dc16f46c5bca149bfefc]# cat diff 
sha256:82b81d779f8352b20e52295afc6d0eab7e61c0ec7af96d85b8cda7800285d97d
[root@localhost f246685cc80c2faa655ba1ec9f0a35d44e52b6f83863dc16f46c5bca149bfefc]# cat cache-id 
bd937f18fcefe148e2ec10f3ee40dc39b984802824b6dc6856a637f150ba95b8
```

再看第三个layer，也就是最上层的layer，chainID是`160a8bd939a9421818f499ba4fbfaca3dd5c86ad7a6b97b6889149fd39bd91dd`：
``` sh
[root@localhost 160a8bd939a9421818f499ba4fbfaca3dd5c86ad7a6b97b6889149fd39bd91dd]# ls
cache-id  diff  parent  size  tar-split.json.gz
[root@localhost 160a8bd939a9421818f499ba4fbfaca3dd5c86ad7a6b97b6889149fd39bd91dd]# cat parent 
sha256:f246685cc80c2faa655ba1ec9f0a35d44e52b6f83863dc16f46c5bca149bfefc
[root@localhost 160a8bd939a9421818f499ba4fbfaca3dd5c86ad7a6b97b6889149fd39bd91dd]# cat diff 
sha256:7ab428981537aa7d0c79bc1acbf208c71e57d9678f7deca4267cc03fba26b9c8
[root@localhost 160a8bd939a9421818f499ba4fbfaca3dd5c86ad7a6b97b6889149fd39bd91dd]# cat cache-id 
85e9e12c94ffd03ff388234a1eb68c13d70a72d4c413aaffeee6d81632c495c5
```

可以看出`layerdb/sha256`下各个layer清晰的记录了各层之间的堆叠关系。

### cache-id
imagedb下面保存的是image的config信息，layerdb下面保存的是各层之间的描述信息以及堆叠关系，那layer的具体内容在哪里呢？
结论：layer的内容存放在`/var/lib/docker/<STORAGE-DRIVER>`下面，本系统就在`/var/lib/docker/overlay2`下面。

进入该文件夹可以发现一个一个的sha256格式的目录，那这个sha256格式的名字是layerID还是chainID呢？
其实都不是，还记的每层下面都有一个cache-id的文件么？对，cache-id文件中的sha256内容指出了在overlay2文件系统中该层对应的目录。
```sh
[root@localhost overlay2]# ls ef8fb5e2c72a523c58c247aeb9bbb36d691ce7720145ff378ebf3714fa8d3e7f
diff  link
[root@localhost overlay2]# cat ef8fb5e2c72a523c58c247aeb9bbb36d691ce7720145ff378ebf3714fa8d3e7f/link 
MVB5STDEZWHO54D642CLYZYNEH

[root@localhost overlay2]# ls bd937f18fcefe148e2ec10f3ee40dc39b984802824b6dc6856a637f150ba95b8
diff  link  lower  merged  work
[root@localhost overlay2]# cat bd937f18fcefe148e2ec10f3ee40dc39b984802824b6dc6856a637f150ba95b8/link 
NUMROUBW7TBBLT56IWT4OL53EZ
[root@localhost overlay2]# cat bd937f18fcefe148e2ec10f3ee40dc39b984802824b6dc6856a637f150ba95b8/lower 
l/MVB5STDEZWHO54D642CLYZYNEH

[root@localhost overlay2]# ls 85e9e12c94ffd03ff388234a1eb68c13d70a72d4c413aaffeee6d81632c495c5
diff  link  lower  merged  work
[root@localhost overlay2]# cat 85e9e12c94ffd03ff388234a1eb68c13d70a72d4c413aaffeee6d81632c495c5/link 
V47ZAVU47VNVE3B7TVCZIGKGOV
[root@localhost overlay2]# cat 85e9e12c94ffd03ff388234a1eb68c13d70a72d4c413aaffeee6d81632c495c5/lower 
l/NUMROUBW7TBBLT56IWT4OL53EZ:l/MVB5STDEZWHO54D642CLYZYNEH
```
如果你熟悉overlay2文件系统，那么对上述格式就不会陌生，可以参见：
* [docker overlay2](../storage/sd_overlay2.md)



