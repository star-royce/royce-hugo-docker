#!/bin/bash
echo "Start Blog Update..."

git pull

docker build --build-arg CACHEBUST=$(date +%s) --rm -t royce-hugo-docker .

# docker run --name royce-blog -d -p 1880:1880  royce-hugo-docker

docker restart 4d65bd8b8abd