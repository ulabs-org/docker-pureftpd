FROM alpine:3.10

ENV TERM=xterm

# Prepare ENVs:
ENV VERSION 1.0.49
ENV UID     5001
ENV GID     82
ENV URL     https://download.pureftpd.org/pub/pure-ftpd/releases/pure-ftpd-${VERSION}.tar.gz

ENV DEPS \
  g++ \
  gcc \
  make \
  libc-dev

# Build and install pure-ftpd:
RUN set -x \
    && apk add --no-cache --virtual .build-deps \
        ca-certificates \
        curl \
        $DEPS \
    && curl -fSL ${URL} -o archive.tgz \
    && tar -xf archive.tgz \
    && rm archive.tgz \
    && mkdir -p /usr/local \
    && ls -la / \
    && mv pure-ftpd-${VERSION} /usr/local/pureftpd \
    && cd /usr/local/pureftpd \
    && ./configure \
      --prefix=/usr \
      --without-unicode \
      # Minimal fail on `not defined modernformat`
      # --with-minimal \ 
      --with-throttling  \
      --with-puredb \
      --with-altlog \
    && make \
    && make install \
    && make clean \
    && cd / \
    && rm -rf /usr/local/pureftpd \
    # create groups:
    && addgroup ftpusers \
    && addgroup -Sg ${GID} www-data 2>/dev/null \
    # create users:
    && adduser -D -h /var/ftp -u 5000 -G ftpusers ftpusers \
    && adduser -h /var/www -s /usr/sbin/nologin -H -u ${UID} -D -G www-data www-data \
    # set rights:
    && chown -hR ftpusers:ftpusers /var/ftp \
    && mkdir -p /etc/pure-ftp \
    && touch /etc/pure-ftp/.passwd \
    && pure-pw mkdb /etc/pure-ftp/pureftpd.pdb -f /etc/pure-ftp/.passwd \
    # set logs:
    && ln -sf /dev/stdout /var/log/pureftpd.log \
    # remove deps:
    && apk del .build-deps \
    && rm -rf /var/cache/apk/*
CMD ["/usr/sbin/pure-ftpd", "-O", "clf:/var/log/pureftpd.log", "-14AEH", "-S", "21" "-p" "33000:35000" "-d" "-l" "/etc/pure-ftpd/pureftpd.pdb"]