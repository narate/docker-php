FROM php:7.1-fpm-alpine

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
RUN rm -rf /tmp/* /var/cache/apk/*

