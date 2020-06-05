FROM alpine:latest AS builder

LABEL maintainer=private.royce@gmail.com

ENV HUGO_VERSION=0.72.0
ENV HUGO_EXTENDED=_extended
ENV CADDY_VERSION =v2.0.0-beta.15

#RUN apk add --update libc6-compat libstdc++ \
#    && ADD https://github.com/caddyserver/caddy/releases/download/v2.0.0-beta.15/caddy2_beta15_linux_amd64 /tmp \
#    && mv /tmp/caddy2_beta15_linux_amd64 /tmp/caddy \
#    && ADD hugo_extended_0.72.0_Linux-64bit.tar.gz /usr/local/bin/

RUN apk add --update libc6-compat libstdc++ \
    && ADD https://github.com/caddyserver/caddy/releases/download/v2.0.0-beta.15/caddy2_beta15_linux_amd64 /tmp \
    && mv /tmp/caddy2_beta15_linux_amd64 /tmp/caddy \
    && curl https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo${HUGO_EXTENDED}_${HUGO_VERSION}_Linux-64bit.tar.gz \
     | tar -xjC /usr/local/bin/ \
    && make -C /usr/local/bin/

# 让tmp目录在后续步骤中可用
WORKDIR /tmp

ENV GIT_REPOSITORY=https://github.com/star-royce/royce-hugo.git
ENV GIT_REPOSITORY_NAME=royce-hugo

RUN apk --no-cache add git \
    && mkdir project \
    && git clone ${GIT_REPOSITORY} /tmp/project \
    && cd /tmp/project/${GIT_REPOSITORY} \
    && RUN hugo

FROM alpine:latest as runner

WORKDIR /tmp

RUN COPY --from=0 /tmp/caddy /usr/bin/caddy \
    && COPY --from=0 /tmp/${GIT_REPOSITORY_NAME}/public ./public/ \
    && ADD Caddyfile . \
    && chmod +x /usr/bin/caddy \
    && CMD caddy run -config /tmp/Caddyfile --adapter caddyfile \
    && EXPOSE 1880
