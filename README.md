# hugo-docker
A Docker image for websites built by hugo


## How to use

### 个人hugo源码仓库(存放着个人博客信息的仓库)

- 修改 Dockerfile 的内容

  - ENV GIT_REPOSITORY
  - ENV GIT_REPOSITORY_NAME
- 端口号修改
  - DockerFile `EXPOSE` 参数为端口号，如果有端口号冲突，可以修改此参数值
  - 一旦 DockerFile `EXPOSE` 参数发生变化，Caddyfile 参数需要随之变更

### build image

```
docker build --build-arg CACHEBUST=$(date +%s) --rm -t royce-hugo-docker .
```

### run container

```
docker run --name royce-blog -d -p 1880:1880  royce-hugo-docker
```