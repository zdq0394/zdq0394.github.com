# docker buildx instance安装harbor ca
BUILDER=$(docker ps | grep buildkitd | cut -f1 -d' ')
docker cp YOUR-CA.crt $BUILDER:/usr/local/share/ca-certificates/
docker exec $BUILDER update-ca-certificates
docker restart $BUILDER
