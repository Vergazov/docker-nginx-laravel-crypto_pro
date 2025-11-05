FROM php:8.3-fpm

ARG UID=1000
ARG GID=1000

RUN apt-get update && apt-get install -y \
    nano \
    cron \
    supervisor \
    procps \
    git \
    libzip-dev \
    libpng-dev \
    libonig-dev \
    zip \
    unzip \
    libjpeg-dev \
    libfreetype6-dev \
    mc \
    make \
    libboost-dev \
    libxml2-dev \
    libicu-dev \
    libsodium-dev \
    libwebp-dev \
    libxslt1-dev \
    g++ \
    mariadb-client \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install \
        pdo \
        pdo_mysql \
        pcntl \
        gd \
        bcmath \
        intl \
        mbstring \
        sodium \
        zip \
        soap \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN pecl install xdebug \
    redis \
    && docker-php-ext-enable xdebug redis \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


COPY config/php/xdebug.ini /usr/local/etc/php/conf.d

# Install and configure Crypto Pro
COPY programs/crypto-pro /opt

RUN /opt/linux-amd64_deb/./install.sh lsb-cprocsp-devel cprocsp-pki-cades
RUN sed -i 's|^PHPDIR *=.*|PHPDIR = /usr/local/include/php/|' /opt/phpcades/Makefile.unix

WORKDIR /opt/phpcades

RUN eval `/opt/cprocsp/src/doxygen/CSP/../setenv.sh --64`; make -f Makefile.unix
RUN ln -s /opt/phpcades/libphpcades.so /usr/local/lib/php/extensions/no-debug-non-zts-20230831/libphpcades.so
RUN echo "extension=libphpcades.so" > /usr/local/etc/php/conf.d/docker-php-ext-libphpcades.ini

# Install composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Create Group with GID
RUN addgroup --gid ${GID} ava

# Create user with UID and add in group
RUN adduser \
    --uid ${UID} \
    --disabled-password \
    --gecos "" \
    --ingroup ava \
    ava

    # попробовать будет ли работать без этой директивыw
ENV HOME=/home/ava

WORKDIR /var/www/html

USER ava