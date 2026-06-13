FROM alpine:3.23.0
RUN apk update && apk add --no-cache bash php85 php85-fpm php85-mysqli php85-phar php85-iconv php85-mbstring php85-curl php85-dom php85-xml php85-openssl php85-json php85-tokenizer mysql-client wget curl tar busybox-extras fcgi && ln -s /usr/bin/php85 /usr/bin/php
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp
WORKDIR /var/www/wordpress
COPY ./tools/wordpress.sh /usr/local/bin/wp_setup.sh
RUN chmod +x /usr/local/bin/wp_setup.sh
RUN echo "memory_limit=512M" > /etc/php85/conf.d/memory-limit.ini
ENTRYPOINT [ "/usr/local/bin/wp_setup.sh" ]