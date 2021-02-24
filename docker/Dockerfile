FROM php:7-fpm

ARG WITH_XDEBUG=false

RUN apt-get update \
    && apt-get install -y iputils-ping \
    && docker-php-ext-install mysqli \
    && docker-php-ext-enable mysqli;

RUN if [ $WITH_XDEBUG = "true" ] ; then \
    echo "xdebug.mode=debug" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini; \
    echo "xdebug.client_host=host.docker.internal" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini; \
fi ;