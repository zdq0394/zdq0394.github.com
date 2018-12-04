#! /bin/sh
echo "Start 6 redis nodes..."
REDIS_IMAGE=registry.docker-cn.com/library/redis:5.0.1
CONF_OPTIONS="-v /opt/gopath/src/github.com/zdq0394/scripts/deploy/redis/cluster/redis-conf:/etc/redis"
docker run -d --name=redis0 --hostname=redis0 $CONF_OPTIONS $REDIS_IMAGE redis-server /etc/redis/redis0.conf 
docker run -d --name=redis1 --hostname=redis1 $CONF_OPTIONS $REDIS_IMAGE redis-server /etc/redis/redis1.conf 
docker run -d --name=redis2 --hostname=redis2 $CONF_OPTIONS $REDIS_IMAGE redis-server /etc/redis/redis2.conf
docker run -d --name=redis3 --hostname=redis3 $CONF_OPTIONS $REDIS_IMAGE redis-server /etc/redis/redis3.conf 
docker run -d --name=redis4 --hostname=redis4 $CONF_OPTIONS $REDIS_IMAGE redis-server /etc/redis/redis4.conf 
docker run -d --name=redis5 --hostname=redis5 $CONF_OPTIONS $REDIS_IMAGE redis-server /etc/redis/redis5.conf

echo "Meet 6 nodes..."
docker exec -it redis0 redis-cli cluster meet 172.17.0.3 6379
docker exec -it redis0 redis-cli cluster meet 172.17.0.4 6379
docker exec -it redis0 redis-cli cluster meet 172.17.0.5 6379
docker exec -it redis0 redis-cli cluster meet 172.17.0.6 6379
docker exec -it redis0 redis-cli cluster meet 172.17.0.7 6379

docker exec -it redis0 redis-cli cluster nodes
docker exec -it redis0 redis-cli cluster info

echo "assign slots..."
docker exec -it redis0 redis-cli cluster addslots {0..5461}
docker exec -it redis1 redis-cli cluster addslots {5462..10922}
docker exec -it redis2 redis-cli cluster addslots {10923..16383}

echo "config replicate"
REDIS0_ID=`docker exec -it redis0 redis-cli cluster myid | sed 's/"//g'`
docker exec -it redis3 redis-cli cluster replicate $REDIS0_ID

REDIS1_ID=`docker exec -it redis1 redis-cli cluster myid | sed 's/"//g'`
docker exec -it redis4 redis-cli cluster replicate $REDIS1_ID

REDIS2_ID=`docker exec -it redis2 redis-cli cluster myid | sed 's/"//g'`
docker exec -it redis5 redis-cli cluster replicate $REDIS2_ID
