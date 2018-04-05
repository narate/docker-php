FROM php:7.0-fpm-alpine

MAINTAINER Narate Ketram <rate@tel.co.th>

# apcu
RUN apk update \
	&& docker-php-source extract \
    && apk add --no-cache --virtual .phpize-deps-configure $PHPIZE_DEPS \
    && pecl install apcu \
    && docker-php-ext-enable apcu \
	&& docker-php-source delete

# gd, iconv
RUN apk add --no-cache \
        freetype-dev \
        libjpeg-turbo-dev \
        libpng-dev \
    && docker-php-ext-install -j"$(getconf _NPROCESSORS_ONLN)" iconv \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j"$(getconf _NPROCESSORS_ONLN)" gd

RUN apk add --no-cache bzip2-dev gettext-dev imap-dev icu icu-dev libintl libxslt-dev libxml2-dev libmcrypt libmcrypt-dev
RUN docker-php-ext-install bz2 calendar exif gettext imap intl mysqli pdo_mysql shmop sockets sysvsem sysvshm wddx xsl opcache zip mcrypt
RUN docker-php-ext-configure soap --enable-soap &&  docker-php-ext-install soap

RUN cd /tmp && \
	php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
	php -r "if (hash_file('SHA384', 'composer-setup.php') === '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
	php composer-setup.php && \
	php -r "unlink('composer-setup.php');"

RUN mv /tmp/composer.phar /usr/bin/composer

RUN cd /tmp && \
	wget https://github.com/magento/magento2/archive/2.2.tar.gz && \
	tar -xzvf 2.2.tar.gz && \
	mv magento2-2.2/* /var/www/html && \
	cd /var/www/html && \
	composer install && \
	find var vendor pub/static pub/media app/etc -type f -exec chmod g+w {} \; && \
	find var vendor pub/static pub/media app/etc -type d -exec chmod g+ws {} \; && \
 	chown -R :www-data . && \
 	chmod u+x bin/magento

RUN apk add --no-cache nginx && mkdir -p /run/nginx
RUN rm -rf /tmp/* /var/cache/apk/*

ADD ./start.sh /start.sh
ADD ./nginx.conf /etc/nginx/nginx.conf

CMD ["/start.sh"]

