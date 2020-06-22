FROM alpine:latest AS builder

LABEL maintainer=private.royce@gmail.com

# 指定使用阿里云国内源
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
    && apk add --update git curl tar libc6-compat libstdc++

# caddy下载
ADD https://github.com/caddyserver/caddy/releases/download/v2.0.0-beta.15/caddy2_beta15_linux_amd64 /tmp
RUN mv /tmp/caddy2_beta15_linux_amd64 /tmp/caddy

# 让tmp目录在后续步骤中可用
WORKDIR /tmp

# hugo下载
ENV HUGO_VERSION=0.72.0
RUN wget https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_Linux-64bit.tar.gz \
    && tar -xzf app.tar.gz -C /usr/local/bin && rm -f hugo${HUGO_EXTENDED}_${HUGO_VERSION}_Linux-64bit.tar.gz

## 下太慢，改为本地
#COPY ./soft/caddy2_beta15_linux_amd64 /tmp/caddy
#ADD ./soft/hugo_extended_0.72.0_Linux-64bit.tar.gz /usr/local/bin/
#RUN rm -rf ./soft/hugo_extended_0.72.0_Linux-64bit.tar.gz

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
