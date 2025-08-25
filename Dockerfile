FROM php:8.3-fpm

ARG UID=1000
ARG GID=1000

RUN apt-get update && apt-get install -y \
    nano \
    cron \
    supervisor \
    procps \
    git \
    zip \
    unzip \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    mc \
    make \
    libboost-dev \
    libxml2-dev \
    && docker-php-ext-install pdo pdo_mysql

# Создаём группу с GID
RUN addgroup --gid ${GID} ava

# Создаём пользователя с UID и добавляем в группу
RUN adduser \
    --uid ${UID} \
    --no-create-home \
    --disabled-password \
    --gecos "" \
    --ingroup ava \
    ava

RUN pecl install xdebug \
    && docker-php-ext-enable xdebug

COPY config/php/xdebug.ini /usr/local/etc/php/conf.d

# Настройка и установка Crypto Pro
COPY programs/crypto-pro /opt

RUN /opt/linux-amd64_deb/./install.sh lsb-cprocsp-devel cprocsp-pki-cades
RUN sed -i 's|^PHPDIR *=.*|PHPDIR = /usr/local/include/php/|' /opt/phpcades/Makefile.unix

WORKDIR /opt/phpcades

RUN eval `/opt/cprocsp/src/doxygen/CSP/../setenv.sh --64`; make -f Makefile.unix
RUN ln -s /opt/phpcades/libphpcades.so /usr/local/lib/php/extensions/no-debug-non-zts-20230831/libphpcades.so
RUN echo "extension=libphpcades.so" > /usr/local/etc/php/conf.d/docker-php-ext-libphpcades.ini

# Установка composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html
USER ava