# hugo-docker
A Docker image for websites built by hugo


## How to use


### build image

```
docker build --build-arg CACHEBUST=$(date +%s) --rm -t royce-hugo-docker .
```

### run container

```
docker run --name royce-blog -d -p 1880:1880  royce-hugo-docker
```