#!/bin/bash
echo "Start Blog Update..."

cd $0

echo "cd $0, pull..."

git pull

docker build --rm -t $0 .

docker run --name {container_name} -d -p {host_port}:$1  hugo-docker