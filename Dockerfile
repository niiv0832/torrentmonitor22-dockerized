#------------------------------------------------------------------------------
# Set the base image for subsequent instructions:
#------------------------------------------------------------------------------
FROM alpine:edge
#MAINTAINER none

#------------------------------------------------------------------------------
# Environment variables:
#------------------------------------------------------------------------------
ENV VERSION="1.8.2" \
    RELEASE_DATE="00.00.0000" \
    CRON_TIMEOUT="0 * * * *" \
    PHP_TIMEZONE="UTC" \
    PHP_MEMORY_LIMIT="512M"

#------------------------------------------------------------------------------
# Populate root file system:
#------------------------------------------------------------------------------
ADD rootfs /

#------------------------------------------------------------------------------
# Install:
#------------------------------------------------------------------------------
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk update && \
    apk upgrade && \
#    && apk --no-cache add --update -t deps wget unzip sqlite build-base tar re2c make file curl python2 python2-dev py2-pip \
    apk --no-cache --update add --virtual .deps1 wget unzip sqlite build-base tar re2c make file curl && \
##   
    apk --no-cache --update add \
    bash \
    nginx \
    php7-common \
    php7-cli \
    php7-fpm \
    php7-session \
    php7-curl \
    php7-sqlite3 \
    php7-mysqli \
    php7-pdo_sqlite \
    php7-iconv \
    php7-json \
    php7-ctype\
    php7-zip \
    php7-xml \
    php7-simplexml \
    php7-mbstring \
    gnu-libiconv \
    npm && \
#    && apk add --no-cache \
#           boost-python@edge \
#           boost-system@edge \
#           libressl2.7-libcrypto@edge \
#           libressl2.7-libssl@edge \
#    && apk add --no-cache deluge@testing \
#    && pip install --no-cache-dir automat incremental constantly service_identity \
##
##
    wget -q http://tormon.ru/tm-latest.zip -O /tmp/tm-latest.zip \
    && unzip /tmp/tm-latest.zip -d /tmp/ \
    && rm -f /tmp/TorrentMonitor-master/config.php \
    && mv /tmp/TorrentMonitor-master/* /data/htdocs \
    && cat /data/htdocs/db_schema/sqlite.sql | sqlite3 /data/htdocs/db_schema/tm.sqlite \
    && mkdir -p /var/log/nginx/ \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log \
    ln -sf /dev/stdout /var/log/php-fpm.log && \
##  
##
#------------------------------------------------------------------------------
# Install: http-knocking
#------------------------------------------------------------------------------  
    npm install -g http-knocking && \
#------------------------------------------------------------------------------
# Install: rclone
#------------------------------------------------------------------------------     
    mkdir -p /tmp/rclone  && \
    cd /tmp/rclone && \
    wget -q --no-check-certificate https://downloads.rclone.org/rclone-current-linux-amd64.zip  && \
    unzip rclone-current-linux-amd64.zip && \
    cd /tmp/rclone/rclone-*-linux-amd64 && \
    cp rclone /bin/ && \
    chown root:root /bin/rclone && \
    chmod 755 /bin/rclone && \
    rm -rf /tmp/rclone && \
#------------------------------------------------------------------------------
# Clean
#------------------------------------------------------------------------------     
    apk del --purge .deps1; rm -rf /tmp/* /var/cache/apk/*

ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php

#------------------------------------------------------------------------------
# Set labels:
#------------------------------------------------------------------------------
LABEL ru.korphome.version="${VERSION}" \
      ru.korphome.release-date="${RELEASE_DATE}"

#------------------------------------------------------------------------------
# Set volumes, workdir, expose ports and entrypoint:
#------------------------------------------------------------------------------
VOLUME ["/data/htdocs/db", "/data/htdocs/torrents"]
WORKDIR /
EXPOSE 80 2000
ENTRYPOINT ["/init"]
