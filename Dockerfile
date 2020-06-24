FROM alpine:latest

LABEL maintainer=private.royce@gmail.com

# 指定使用阿里云国内源
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
    && apk add --update git libc6-compat libstdc++

# 下太慢，改为本地
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
    && mkdir /tmp/static \
    && mv public /tmp/static/ \
    && cd /tmp \
    && rm -rf ${GIT_REPOSITORY_NAME}

VOLUME /tmp/static

EXPOSE 1880

CMD ["/bin/bash"]