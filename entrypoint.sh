#!/bin/bash

echo "============================  Start Blog Update... ============================ "

#echo "============================ Git Project Update... ============================ "
#git pull

echo "============================  docker image build... ============================ "
docker build --build-arg CACHEBUST=$(date +%s) --rm -t royce-blog .

echo "============================ docker run royce-blog...============================ "
docker run --name royce-blog -d -p 1880:1880 royce-blog

echo "============================ docker public download...============================ "
docker cp royce-blog:/tmp/public /opt/web/royce-blog/

echo "============================ docker stop ============================ "
docker stop royce-blog

echo "============================ docker rm ============================ "
docker rm royce-blog

echo "============================ docker none image remove... ============================ "
# 不加-f, 则基础的build产生的image不会被清除
docker images|grep none|awk '{print $3 }'|xargs docker rmi

echo "============================ nginx docker restart... ============================ "
docker-compose restart nginx
