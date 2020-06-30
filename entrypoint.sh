#!/bin/bash

echo "============================  Start Blog Update... ============================ "

echo "============================ Git Project Update... ============================ "
git pull

echo "============================  docker image build... ============================ "
docker build --build-arg CACHEBUST=$(date +%s) --rm -t "$0" .

echo "============================ docker run $0...============================ "
docker run --name "$0" -d -p 1880:1880 "$0"

echo "============================ docker public download...============================ "
docker cp "$0":/tmp/public /opt/web/"$0"/

echo "============================ docker stop ============================ "
docker stop "$0"

echo "============================ docker rm ============================ "
docker rm "$0"

echo "============================ docker none image remove... ============================ "
# 不加-f, 则基础的build产生的image不会被清除
docker images|grep none|awk '{print $3 }'|xargs docker rmi

echo "============================ nginx docker restart... ============================ "
docker-compose restart nginx
