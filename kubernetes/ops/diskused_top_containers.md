# 占用磁盘空间最大的容器
* 第一步：找到占用磁盘空间最大的镜像层

切到容器存储目录为/var/lib/docker/overlay2，执行命令`du -s * | sort -nr | head -N`
```sh
[root@docker overlay2]# du -s * | sort -nr | head -3
334636	f6acb9573429712fe4d8b8b786e24d790fae8727f403693874b62a168b174870
159348	86444fb8a5127b41323bef731c14eb764135a7066bb5f904427f53816ff4fe2f
146556	6c21d550b2e37e23b777490d3f3b26c54ed5b98ad615ac833ff4248a288b9530
```

* 第二步：找到该镜像层所属的容器：
```sh
for i in $(docker ps -q ); do echo $i ; docker inspect $i|grep f6acb9573429 ; done
```

* 第三步：根据容器ID找到容器名字
```sh
docker inspect -f '{{ .Name }}' 8b251ce7f7ae
```
