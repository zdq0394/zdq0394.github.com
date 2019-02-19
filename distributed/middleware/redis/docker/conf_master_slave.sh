#! /bin/sh
REDIS_IMAGE=registry.docker-cn.com/library/redis:5.0.1
docker run -d --name=redis0 --hostname=redis0 -v /redis-conf:/etc/redis $REDIS_IMAGE redis-server /etc/redis/redis0.conf 
docker run -d --name=redis1 --hostname=redis1 -v /redis-conf:/etc/redis $REDIS_IMAGE redis-server /etc/redis/redis1.conf 
docker run -d --name=redis2 --hostname=redis2 -v /redis-conf:/etc/redis $REDIS_IMAGE redis-server /etc/redis/redis2.conf
