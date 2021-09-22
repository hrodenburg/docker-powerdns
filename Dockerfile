FROM alpine:3.14
MAINTAINER Christoph Wiechert <wio@psitrax.de>

ENV POWERDNS_VERSION=4.5.1 \
    MYSQL_DEFAULT_AUTOCONF=true \
    MYSQL_DEFAULT_HOST="mysql" \
    MYSQL_DEFAULT_PORT="3306" \
    MYSQL_DEFAULT_USER="root" \
    MYSQL_DEFAULT_PASS="root" \
    MYSQL_DEFAULT_DB="pdns"

RUN apk --update --no-cache add \
      bash \
      libcurl \
      libgcc \
      libpq \
      libstdc++ \
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
      --with-modules="bind gmysql gpgsql gsqlite3" && \
    make && make install-strip && \
    cd / && \
    mkdir -p /etc/pdns/conf.d && \
    addgroup -S pdns && \
    adduser -S -D -H -h /var/empty -s /bin/false -G pdns -g pdns pdns && \
    cp -d /usr/lib/libboost_program_options.so* /tmp && \
    apk del --purge .build-deps && \
    mv /tmp/libboost_program_options.so* /usr/lib/ && \
    rm -rf /tmp/pdns-$POWERDNS_VERSION.tar.bz2 /tmp/pdns-$POWERDNS_VERSION /var/cache/apk/*

ADD pdns.conf /etc/pdns/
ADD entrypoint.sh /

EXPOSE 53/tcp 53/udp

ENTRYPOINT ["/entrypoint.sh"]
