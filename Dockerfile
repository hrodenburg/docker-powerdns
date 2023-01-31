FROM alpine:3.17
MAINTAINER Christoph Wiechert <wio@psitrax.de>

ENV POWERDNS_VERSION=4.7.3 \
    MYSQL_DEFAULT_AUTOCONF=true \
    MYSQL_DEFAULT_HOST="mysql" \
    MYSQL_DEFAULT_PORT="3306" \
    MYSQL_DEFAULT_USER="root" \
    MYSQL_DEFAULT_PASS="root" \
    MYSQL_DEFAULT_DB="pdns" \
    DEFAULT_ENABLE_LMDB="false"

RUN apk --update --no-cache add \
      bash \
      boost1.80-program_options \
      boost1.80-serialization \
      libcurl \
      libgcc \
      libpq \
      libsodium \
      libstdc++ \
      lmdb \
      lua5.3-libs \
      mariadb-client \
      mariadb-connector-c \
      sqlite-libs && \
    apk --update --no-cache add --virtual .build-deps \
      boost-dev \
      curl \
      curl-dev \
      file \
      g++ \
      libsodium-dev \
      lmdb-dev \
      lua5.3-dev \
      make \
      mariadb-connector-c-dev \
      mariadb-dev \
      postgresql-dev \
      sqlite-dev && \
    curl -sSL -o /tmp/pdns-$POWERDNS_VERSION.tar.bz2 https://downloads.powerdns.com/releases/pdns-$POWERDNS_VERSION.tar.bz2 && \
    cd /tmp/ && \
    tar xjf pdns-${POWERDNS_VERSION}.tar.bz2 && \
    cd /tmp/pdns-${POWERDNS_VERSION} && \
    ./configure --prefix="" --exec-prefix=/usr --sysconfdir=/etc/pdns \
      --with-modules="bind gmysql gpgsql gsqlite3 lmdb" \
      --with-libsodium \
      --with-lmdb \
      --enable-unit-tests && \
    make -j4 && make install-strip && \
    cd / && \
    addgroup -S pdns && \
    adduser -S -D -H -h /var/empty -s /bin/false -G pdns -g pdns pdns && \
    apk del --purge .build-deps && \
    rm -rf /tmp/pdns-$POWERDNS_VERSION.tar.bz2 /tmp/pdns-$POWERDNS_VERSION /var/cache/apk/* && \
    mkdir -p /var/lib/pdns && chmod 777 /var/lib/pdns

COPY root/ /

EXPOSE 53/tcp 53/udp

ENTRYPOINT ["/entrypoint.sh"]
