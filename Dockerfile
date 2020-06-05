FROM alpine:latest AS builder

LABEL maintainer=private.royce@gmail.com

RUN apk add --update libc6-compat libstdc++

# 下太慢，改为本地
COPY caddy2_beta15_linux_amd64 /tmp/caddy
ADD hugo_extended_0.72.0_Linux-64bit.tar.gz /usr/local/bin/
RUN rm -rf hugo_extended_0.72.0_Linux-64bit.tar.gz

# 让tmp目录在后续步骤中可用
WORKDIR /tmp

ENV GIT_REPOSITORY=https://github.com/star-royce/royce-hugo.git
ENV GIT_REPOSITORY_NAME=royce-hugo

# 拉取最新代码
RUN apk --no-cache add git \
    && mkdir project \
    && git clone ${GIT_REPOSITORY} /tmp \
    && cd /tmp/${GIT_REPOSITORY} \
    && hugo

FROM alpine:latest as runner

WORKDIR /tmp

COPY --from=0 /tmp/caddy /usr/bin/caddy \
COPY --from=0 /tmp/${GIT_REPOSITORY_NAME}/public ./public/ \
ADD Caddyfile . \
RUN chmod +x /usr/bin/caddy \
CMD caddy run -config /tmp/Caddyfile --adapter caddyfile \
EXPOSE 1880
