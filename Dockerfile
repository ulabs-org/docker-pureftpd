FROM alpine:edge

# Избавляемся от геморроя:
ENV TERM=xterm

# Устанавливаем и подготавливаем pure-ftpd:
RUN apk add --update-cache --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ \
        pure-ftpd \
    && mkdir -p /var/ftp \
    && addgroup ftpusers \
    && adduser -D -h /var/ftp -u 5000 -G ftpusers ftpusers \
    && chown -hR ftpusers:ftpusers /var/ftp \
    && mkdir -p /etc/pure-ftp \
    && touch /etc/pure-ftp/.passwd \
    && pure-pw mkdb /etc/pure-ftp/pureftpd.pdb -f /etc/pure-ftp/.passwd \
    && ln -sf /dev/stdout /var/log/pureftpd.log \
    && rm -rf /var/cache/apk/*

CMD "/usr/sbin/pure-ftpd -O clf:/var/log/pureftpd.log -14AEH -S 21 -p 33000:35000 -d -l /etc/pure-ftpd/pureftpd.pdb"