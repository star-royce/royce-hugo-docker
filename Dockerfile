FROM alpine:latest AS builder

LABEL maintainer=private.royce@gmail.com

RUN apk add --update git libc6-compat libstdc++

#RUN apk add --update git libc6-compat libstdc++ \
#    && apk upgrade \
#    && apk add --no-cache ca-certificates

#ADD https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo${HUGO_EXTENDED}_${HUGO_VERSION}_Linux-64bit.tar.gz /tmp

#WORKDIR /usr/local
#COPY hugo_extended_0.72.0_Linux-64bit.tar.gz /tmp

#ENV HUGO_VERSION=0.72.0
#ENV HUGO_EXTENDED=_extended
#RUN tar -xf /tmp/hugo${HUGO_EXTENDED}_${HUGO_VERSION}_Linux-64bit.tar.gz -C   /usr/local/bin/

ENV CADDY_VERSION =v2.0.0-beta.15

ADD https://github.com/caddyserver/caddy/releases/download/v2.0.0-beta.15/caddy2_beta15_linux_amd64 /tmp

RUN mv /tmp/caddy2_beta15_linux_amd64 /tmp/caddy

ENV GIT_REPOSITORY=https://github.com/star-royce/royce-hugo.git
ENV GIT_REPOSITORY_NAME=royce-hugo

#ENV THEME_GIT_REPOSITORY=https://github.com/dillonzq/LoveIt.git
#ENV THEME_NAME=LoveIt

RUN apk --no-cache add git

WORKDIR /tmp/project

RUN git clone ${GIT_REPOSITORY}

RUN cd ${GIT_REPOSITORY_NAME}

#RUN cd ${GIT_REPOSITORY_NAME} \
#    && mkdir themes \
#    && cd /tmp/blog/themes \
#    && git clone ${THEME_GIT_REPOSITORY}

WORKDIR /tmp/${GIT_REPOSITORY_NAME}

#RUN sh -c 'sed -i "s/theme = \".*\"/theme = \"$THEME_NAME\"/" config.toml'

RUN hugo 

FROM alpine:latest as runner

WORKDIR /tmp

COPY --from=0 /tmp/caddy /usr/bin/caddy

COPY --from=0 /tmp/${GIT_REPOSITORY_NAME}/public ./public/

ADD Caddyfile .

RUN chmod +x /usr/bin/caddy

CMD caddy run -config /tmp/Caddyfile --adapter caddyfile

EXPOSE 1880
