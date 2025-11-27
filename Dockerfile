FROM php:8.3-fpm

ARG UID=1000
ARG GID=1000
ENV USERNAME=www-data
ENV APP_HOME /var/www/html

RUN apt-get update && apt-get install -y \
    opensc \
    pcscd \
    pcsc-tools \
    nano \
    sudo \
    cron \
    supervisor \
    procps \
    usbutils \ 
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
    libccid \
    libpcsclite1 \ 
    libusb-1.0-0 \
    libudev1 \
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

RUN mkdir -p $APP_HOME/public && \
    mkdir -p /home/$USERNAME && chown $USERNAME:$USERNAME /home/$USERNAME \
    && usermod -o -u $UID $USERNAME -d /home/$USERNAME \
    && groupmod -o -g $GID $USERNAME \
    && chown -R ${USERNAME}:${USERNAME} $APP_HOME

# put php config for Laravel
COPY ./config/php/www.conf /usr/local/etc/php-fpm.d/www.conf
COPY ./config/php/php.ini /usr/local/etc/php/php.ini

COPY config/php/xdebug.ini /usr/local/etc/php/conf.d

# Install and configure Crypto Pro
COPY programs/crypto-pro /opt

RUN /opt/linux-amd64_deb/./install.sh lsb-cprocsp-devel cprocsp-pki-cades
RUN sed -i 's|^PHPDIR *=.*|PHPDIR = /usr/local/include/php/|' /opt/phpcades/Makefile.unix

WORKDIR /opt/phpcades/

RUN eval `/opt/cprocsp/src/doxygen/CSP/../setenv.sh --64`; make -f Makefile.unix
RUN ln -s /opt/phpcades/libphpcades.so /usr/local/lib/php/extensions/no-debug-non-zts-20230831/libphpcades.so
RUN echo "extension=libphpcades.so" > /usr/local/etc/php/conf.d/docker-php-ext-libphpcades.ini

# Install composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# add supervisor
RUN mkdir -p /var/log/supervisor
COPY --chown=root:root ./config/general/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY --chown=root:crontab ./config/general/cron /var/spool/cron/crontabs/root
RUN chmod 0600 /var/spool/cron/crontabs/root

WORKDIR $APP_HOME

USER ${USERNAME}

COPY --chown=${USERNAME}:${USERNAME} . $APP_HOME/

USER root