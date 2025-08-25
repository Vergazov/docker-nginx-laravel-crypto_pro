# 🚀 Laravel/php/nginx in Docker project

## 🛠️ Deploy

- make up

- make composer-install

- make key-generate

- cd src

- cp .env.example .env

## 📃 Make command list

- up - запустить контейнеры
- down - остановить контейнеры
- build - пересобрать образы
- bash-php - запустить bash внутри PHP контейнера
- composer-install - установить composer зависимости
- key-generate - сгенерировать Laravel ключ
- php - выполнить команду PHP (использование: make php cmd="artisan migrate")
- artisan - выполнить Artisan (make artisan cmd="migrate")
- cache-clear - очистить кеш Laravel
- migrate - выполнить миграции Laravel

## 🔧 Additional tools

- Crypto pro
- Xdebug