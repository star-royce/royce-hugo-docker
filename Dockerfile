FROM alpine:latest AS builder

LABEL maintainer=private.royce@gmail.com

RUN apk add --update git libc6-compat libstdc++

# 下太慢，改为本地
COPY ./soft/caddy2_beta15_linux_amd64 /tmp/caddy
ADD ./soft/hugo_extended_0.72.0_Linux-64bit.tar.gz /usr/local/bin/
RUN rm -rf ./soft/hugo_extended_0.72.0_Linux-64bit.tar.gz

# 让tmp目录在后续步骤中可用
WORKDIR /tmp

ENV GIT_REPOSITORY=https://github.com/star-royce/royce-hugo.git
ENV GIT_REPOSITORY_NAME=royce-hugo

# 这一步开始，不使用缓存, CACHEBUST由build指令传入当前时间
ARG CACHEBUST=1

# 拉取最新代码
RUN git clone ${GIT_REPOSITORY} \
    && cd /tmp/${GIT_REPOSITORY_NAME} \
    && hugo \
    && mv public /tmp \
    && cd /tmp \
    && rm -rf ${GIT_REPOSITORY_NAME}

FROM alpine:latest as runner

WORKDIR /tmp

COPY --from=0 /tmp/caddy /usr/bin/caddy
COPY --from=0 /tmp/public ./public/
ADD Caddyfile .
RUN chmod +x /usr/bin/caddy
CMD caddy run -config /tmp/Caddyfile --adapter caddyfile
EXPOSE 1880
