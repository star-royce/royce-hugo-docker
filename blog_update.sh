#!/bin/bash
echo "Start Blog Update..."

echo "Git Project Update..."
git pull

echo "docker image build..."
docker build --build-arg CACHEBUST=$(date +%s) --rm -t royce-hugo-docker .

# docker run --name royce-blog -d -p 1880:1880  royce-hugo-docker
echo "docker container restart..."
docker restart 4d65bd8b8abd