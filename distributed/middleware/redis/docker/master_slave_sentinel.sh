#! /bin/sh
REDIS_IMAGE=registry.docker-cn.com/library/redis:5.0.1
docker run -d --name=redis0 --hostname=redis0 -v /redis-conf:/etc/redis $REDIS_IMAGE redis-server /etc/redis/redis0.conf 
docker run -d --name=redis1 --hostname=redis1 -v /redis-conf:/etc/redis $REDIS_IMAGE redis-server /etc/redis/redis1.conf 
docker run -d --name=redis2 --hostname=redis2 -v /redis-conf:/etc/redis $REDIS_IMAGE redis-server /etc/redis/redis2.conf

docker run -d --name=sentinel1 --hostname=sentinel1 -v /redis-conf:/etc/redis $REDIS_IMAGE redis-server /etc/redis/sentinel1.conf --sentinel
docker run -d --name=sentinel2 --hostname=sentinel2 -v /redis-conf:/etc/redis $REDIS_IMAGE redis-server /etc/redis/sentinel2.conf --sentinel
docker run -d --name=sentinel3 --hostname=sentinel3 -v /redis-conf:/etc/redis $REDIS_IMAGE redis-server /etc/redis/sentinel3.conf --sentinel

