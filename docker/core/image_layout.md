# 镜像及其layer存储分析
本文以一个镜像nginx:latest为例来分析镜像及其layer是如何存储在磁盘上的。
## 环境
* Centos 7.4; 内核版本4.17.3-1.el7.elrepo.x86_64
* Docker Version: 1.13.1
* Storage Driver: overlay2
## 镜像
若无特殊指定，docker daemon使用目录`/var/lib/docker`存放资源。

镜像`image`存放在`/var/lib/docker/image/<STORAGE-DRIVER>`下。当前系统采用overlay2，也就存放在`/var/lib/docker/image/overlay2`目录下。

该目录下包含3个文件夹和一个json文件（repositories.json）：
* repositories.json：所有镜像的索引文件，可以认为是一个map，镜像(repo:tag或者repo@digest)到Image-ID的映射。
* imagedb：所有镜像的描述信息都存放在该目录及其子目录下。
* layerdb：镜像的各个层的描述信息（子目录sha256）；容器的读写层的描述信息也在该目录下（子目录mounts）。
* distribution：与docker registry相关，主要描述diff-id和digest之间的映射关系。

### repositories.json
该文件描述了本机所有镜像的索引，如下所示：
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
可以看到在repository.json中记录了镜像tag与Image-ID（Image-ID是镜像的config文件内容的sha256哈希）之间的映射关系。
通过执行`docker images`命令可以看到，此处的IMAGE ID及为repository.json中的Image-ID。
```sh
[root@dqvm overlay2]# docker images
REPOSITORY  TAG     IMAGE ID        CREATED             SIZE
nginx       latest  ae513a47849c    6 months ago        109 MB
```

### imagedb
进入imagedb目录，发现下面有2个子目录(content和metadata)。

略过metadata，直接进入content/sha256目录。
该目录下存放的是各个镜像的config文件，文件名就是各个config文件内容的sha256哈希值。
比如，上面提到的nginx镜像，ae513a47849c895a155ddfb868d6ba247f60240ec8495482eca74c4a2c13a881，文件内容的sha256sum刚好也是ae513a47849c895a155ddfb868d6ba247f60240ec8495482eca74c4a2c13a881。
```sh
# cat ae513a47849c895a155ddfb868d6ba247f60240ec8495482eca74c4a2c13a881 | sha256sum
ae513a47849c895a155ddfb868d6ba247f60240ec8495482eca74c4a2c13a881  -
```

查看该文件的内容（忽略了其他信息，只保留rootfs部分）：
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

可以看出该镜像包括3个layer，自底向上分别是：
* d626a8ad97a1f9c1f2c4db3814751ada64f60aed927764a3f994fcd88363b659
* 82b81d779f8352b20e52295afc6d0eab7e61c0ec7af96d85b8cda7800285d97d
* 7ab428981537aa7d0c79bc1acbf208c71e57d9678f7deca4267cc03fba26b9c8

那这三个layer是如何存放在磁盘上的呢？

### layerdb
镜像的layer信息是存在layerdb目录中的，直观的想，针对每个layer以layer的DIFF-ID创建一个文件夹存放，还保留了之间的关系。不过docker不是这么做的，Docker引入了chain的概念，针对每个layer，对应的DIFF-ID生成了一个CHAIN-ID，以CHAIN-ID为名创建文件夹。

CHAIN-ID的计算方法如下：
* 最底层layer的CHAIN-ID和layer的DIFF-ID是相同的。
* CHAIN-ID(n) = digest(CHAIN-ID(n-1)+" "+DIFF-ID(n))

本镜像的3个layer对应的CHAIN-ID分别如下：
* d626a8ad97a1f9c1f2c4db3814751ada64f60aed927764a3f994fcd88363b659
* f246685cc80c2faa655ba1ec9f0a35d44e52b6f83863dc16f46c5bca149bfefc
* 160a8bd939a9421818f499ba4fbfaca3dd5c86ad7a6b97b6889149fd39bd91dd
上面2层的计算命令如下：
```sh
# echo -n "sha256:d626a8ad97a1f9c1f2c4db3814751ada64f60aed927764a3f994fcd88363b659 sha256:82b81d779f8352b20e52295afc6d0eab7e61c0ec7af96d85b8cda7800285d97d" | sha256sum 
f246685cc80c2faa655ba1ec9f0a35d44e52b6f83863dc16f46c5bca149bfefc  -

# echo -n "sha256:f246685cc80c2faa655ba1ec9f0a35d44e52b6f83863dc16f46c5bca149bfefc sha256:7ab428981537aa7d0c79bc1acbf208c71e57d9678f7deca4267cc03fba26b9c8" | sha256sum 
160a8bd939a9421818f499ba4fbfaca3dd5c86ad7a6b97b6889149fd39bd91dd  -
```

layerdb目录下有3个文件夹，镜像的层的信息存储在目录sha256下面，在该文件夹包括了所有镜像的layer，文件夹的命名都是对应的层的CHAIN-ID。
```sh
# ls
mounts  sha256  tmp
```

1. 先看最底层的layer`d626a8ad97a1f9c1f2c4db3814751ada64f60aed927764a3f994fcd88363b659`，
其CHAIN-ID和DIFF-ID一致，也是`d626a8ad97a1f9c1f2c4db3814751ada64f60aed927764a3f994fcd88363b659`。
``` sh
[root@localhost d626a8ad97a1f9c1f2c4db3814751ada64f60aed927764a3f994fcd88363b659]# ls
cache-id  diff  size  tar-split.json.gz
[root@localhost d626a8ad97a1f9c1f2c4db3814751ada64f60aed927764a3f994fcd88363b659]# cat diff 
sha256:d626a8ad97a1f9c1f2c4db3814751ada64f60aed927764a3f994fcd88363b659
[root@localhost d626a8ad97a1f9c1f2c4db3814751ada64f60aed927764a3f994fcd88363b659]# cat cache-id 
ef8fb5e2c72a523c58c247aeb9bbb36d691ce7720145ff378ebf3714fa8d3e7f
```
其文件下包含了4文件（夹）：
* diff文件包含了其对应的layer的DIFF-ID。
* cache-id：指出了该层内容在storage driver（overlay2）中的存储位置。

2. 然后进入第二个layer，CHAIN-ID是`f246685cc80c2faa655ba1ec9f0a35d44e52b6f83863dc16f46c5bca149bfefc`。

与最底层不同，该文件夹下多了一个名为parent的文件，内容为下层layer的CHAIN-ID；
同样diff内容为该层的DIFF-ID。
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

3. 再看第三个layer，也就是最上层的layer，CHAIN-ID是`160a8bd939a9421818f499ba4fbfaca3dd5c86ad7a6b97b6889149fd39bd91dd`：
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

综上可以看出`layerdb/sha256`下各个layer清晰的记录了各层之间的堆叠关系。

### cache-id
imagedb下面保存的是image的config信息，layerdb下面保存的是各层之间的描述信息以及堆叠关系，那layer的具体内容在哪里呢？
结论：layer的内容存放在`/var/lib/docker/<STORAGE-DRIVER>`目录中，本系统就是在`/var/lib/docker/overlay2`下面。

进入`/var/lib/docker/overlay2`可以发现一个个的sha256格式的目录，那这个sha256格式的名字是DIFF-ID还是CHAIN-ID呢？

其实都不是，我们知道镜像的每层都有一个cache-id的文件。是的，cache-id文件中的sha256内容指出了在overlay2文件系统中该层对应的目录。

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

如果熟悉overlay2文件系统，那么对上述格式就不会陌生，不熟悉的可以参考：[docker overlay2](../storage/sd_overlay2.md)



