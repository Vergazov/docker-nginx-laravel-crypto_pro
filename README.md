# 🚀 nginx/laravel/mysql in Docker

## 🛠️ Deploy

    make up

## 🔷 Install Laravel (if need):

    make laravel-install
    make env-copy
    make key-generate

❗If you need a specific version of framework, use:
    
    make laravel-install version=10.0


## 📃 Make command list

    up - start containers
    down - stop containers
    build - rebuild
    composer-install - install composer dependencies
    key-generate - generate a Laravel key
    bash-php - run bash inside a PHP container
    bash-php-root - run bash inside the PHP container as root

## 🔧 Additional tools

    Crypto pro
    Xdebug

## 📌 Additional Info

    ❗Crypto pro disabled by deafault, to enable it, go to the dockefile