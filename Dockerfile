#------------------------------------------------------------------------------
# Set the base image for subsequent instructions:
#------------------------------------------------------------------------------
FROM alpine:edge
MAINTAINER Siarhei Navatski <navatski@gmail.com>, Andrey Aleksandrov <alex.demion@gmail.com>, Roman Smirnov <roman@smirnov.tk>

#------------------------------------------------------------------------------
# Environment variables:
#------------------------------------------------------------------------------
ENV VERSION="1.7.7" \
    RELEASE_DATE="06.08.2018" \
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
RUN apk update \
    && apk upgrade \
    && apk add --no-cache --update -t deps wget unzip sqlite build-base tar re2c make file curl python2 py2-pip \
    && apk add --no-cache nginx ca-certificates libressl2.7-libssl

RUN apk upgrade -U && \
    apk --update --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community add \
    php7-common php7-cli php7-fpm php7-session php7-curl php7-sqlite3 php7-mysqli php7-pdo_sqlite php7-iconv php7-json php7-ctype php7-zip php7-simplexml \

RUN apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing deluge@testing \
    && pip install --no-cache-dir automat incremental constantly service_identity \
    && wget -q http://tormon.ru/tm-latest.zip -O /tmp/tm-latest.zip \
    && unzip /tmp/tm-latest.zip -d /tmp/ \
    && rm -f /tmp/TorrentMonitor-master/config.php \
    && mv /tmp/TorrentMonitor-master/* /data/htdocs \
    && cat /data/htdocs/db_schema/sqlite.sql | sqlite3 /data/htdocs/db_schema/tm.sqlite \
    && mkdir -p /var/log/nginx/ \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log \
    && ln -sf /dev/stdout /var/log/php-fpm.log \
    && apk del --purge deps; rm -rf /tmp/* /var/cache/apk/*

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
EXPOSE 80
ENTRYPOINT ["/init"]
