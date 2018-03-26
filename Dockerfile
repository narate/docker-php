FROM php:7-fpm-alpine3.7

MAINTAINER Narate Ketram <rate@tel.co.th>

# apcu
RUN docker-php-source extract \
    && apk add --no-cache --virtual .phpize-deps-configure $PHPIZE_DEPS \
    && pecl install apcu \
    && docker-php-ext-enable apcu
    #&& apk del .phpize-deps-configure \
    #&& docker-php-source delete

# mcrypt
RUN apk add --no-cache libmcrypt libmcrypt-dev \
    && pecl install mcrypt-1.0.1 \
    && docker-php-ext-enable mcrypt

# gd, iconv
RUN apk add --update --no-cache \
        freetype-dev \
        libjpeg-turbo-dev \
        libpng-dev \
    && docker-php-ext-install -j"$(getconf _NPROCESSORS_ONLN)" iconv \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j"$(getconf _NPROCESSORS_ONLN)" gd

RUN apk add --no-cache bzip2-dev gettext-dev imap-dev icu icu-dev libintl libxslt-dev libxml2-dev
RUN docker-php-ext-install bz2 calendar exif gettext imap intl mysqli pdo_mysql shmop sockets sysvsem sysvshm wddx xsl opcache

