#! /bin/sh
REDIS_IMAGE=registry.docker-cn.com/library/redis:5.0.1
docker run -d --name=redis0 --hostname=redis0 $REDIS_IMAGE
docker run -d --name=redis1 --hostname=redis1 $REDIS_IMAGE redis-server --slaveof  172.17.0.2 6379
docker run -d --name=redis2 --hostname=redis2 $REDIS_IMAGE redis-server --slaveof  172.17.0.2 6379