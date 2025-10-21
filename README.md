# 🚀 nginx/laravel/mysql in Docker

## 🛠️ Deploy

    make up

## 🔷 If you need to work with an existing Laravel project:
    before make up:
        create the /src folder in the root of the project
        make up
        make composer-install
        copy .env.example file
        make key-generate

## 🔷 Install Laravel (if need):

    make laravel-install
    make env-copy
    make key-generate

❗If you need a specific version of framework, use:
    
    make laravel-install version=10.0

## 🔷 If Laravel is not needed

    make init

❗Initializes an empty php project with autoloading of classes


## 📃 Make command list

    up - start containers
    down - stop containers
    laravel-install - install laravel app in /src folder
    build - rebuild
    composer-install - install composer dependencies
    key-generate - generate a Laravel key
    bash - run bash inside a PHP container
    bash-root - run bash inside the PHP container as root
    init - initiates a simple php project with autoload

## 🔧 Additional tools

    Crypto pro
    Xdebug

## 📌 Additional Info

    ❗Crypto pro disabled by deafault, to enable it, go to the dockefile