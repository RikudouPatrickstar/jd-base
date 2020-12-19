FROM node:lts-alpine
LABEL maintainer="Evine Deng <evinedeng@foxmail.com>"
ARG JD_BASE_URL=https://gitee.com/evine/jd-base
ARG JD_BASE_BRANCH=v3
ARG JD_SCRIPTS_URL=https://gitee.com/lxk0301/jd_scripts
ARG JD_SCRIPTS_BRANCH=master
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.bfsu.edu.cn/g' /etc/apk/repositories \
    && apk update -f \
    && apk upgrade \
    && apk --no-cache add -f bash \
                             coreutils \
                             moreutils \
                             git \
                             wget \
                             curl \
                             nano \
                             tzdata \
                             perl \
                             openssl \
    && rm -rf /var/cache/apk/*
ENV LANG=zh_CN.UTF-8 \
    SHELL=/bin/bash \
    PS1="\u@\h:\w \$ " \
    JD_DIR=/jd \
    JS_DIR=${JD_DIR}/scripts
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod 777 /usr/local/bin/entrypoint.sh \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone \
    && git clone -b ${JD_BASE_BRANCH} ${JD_BASE_URL} ${JD_DIR} \
    && git clone -b ${JD_SCRIPTS_BRANCH} ${JD_SCRIPTS_URL} ${JS_DIR} \
    && cd ${JS_DIR} \
    && npm install
WORKDIR ${JD_DIR}
ENTRYPOINT entrypoint.sh
