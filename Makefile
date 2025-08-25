# Makefile

# Цвета для красивого вывода
GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
RESET  := $(shell tput -Txterm sgr0)

# Путь к текущему Makefile
MAKEFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))

# Показ справки
.PHONY: help
help:
	@echo ''
	@echo '🛠️  Доступные команды:'
	@awk ' \
		BEGIN { commands = "" } \
		/^[a-zA-Z0-9_-]+:/ { \
			match($$0, /## (.*)/, arr); \
			command = substr($$1, 1, index($$1, ":")-1); \
			if (arr[1] != "") { \
				printf "  ${YELLOW}%-20s${RESET} %s\n", command, arr[1]; \
			} \
		} \
	' $(MAKEFILE_PATH)
	@echo ''

# Запуск сервисов
.PHONY: up
up: ## Запустить контейнеры
	@echo '${GREEN}Запуск контейнеров...${RESET}'
		docker compose up -d

# Остановка сервисов
.PHONY: down
down: ## Остановить контейнеры
	@echo '${GREEN}Остановка контейнеров...${RESET}'
		docker compose down

# Пересборка сервисов
.PHONY: build
build: ## Пересобрать образы
	@echo '${GREEN}Пересборка образов'
		docker compose up -d --build

# Bash в контейнере PHP под root
.PHONY: bash-php-root
bash-php-root: ## Запустить bash внутри PHP контейнера
	@echo '${GREEN}Запуск bash нутри PHP контейнера...${RESET}'
		docker compose exec -u root php bash

# Bash в контейнере PHP
.PHONY: bash-php
bash-php: ## Запустить bash внутри PHP контейнера
	@echo '${GREEN}Запуск bash нутри PHP контейнера...${RESET}'
		docker compose exec php bash

# Установить зависимости composer
.PHONY: composer-install
composer-install: ## Установить composer зависимости
	@echo '${GREEN}Установка зависимостей composer...${RESET}'
		docker compose exec php composer install --optimize-autoloader --prefer-dist --no-dev

# Генерация laravel ключа
.PHONY: key-generate
key-generate: ## Сгенерировать Laravel ключ
	@echo '${GREEN}Генерация ключа...${RESET}'
		docker compose exec php php artisan key:generate

# Команда для PHP (пример: make php "artisan list")
.PHONY: php
php: ## Выполнить команду PHP (использование: make php cmd="artisan migrate")
	@echo '${GREEN}Выполнение PHP команды: $(cmd)${RESET}'
	docker compose exec php php $(cmd)

# Laravel Artisan
.PHONY: artisan
artisan: ## Выполнить Artisan (make artisan cmd="migrate")
	@echo '${GREEN}Выполнение Artisan: $(cmd)${RESET}'
	docker compose exec php php artisan $(cmd)

# Очистка кеша Laravel
.PHONY: cache-clear
cache-clear: ## Очистить кеш Laravel
	@echo '${GREEN}Очистка кеша...${RESET}'
	docker compose exec php php artisan config:clear
	docker compose exec php php artisan cache:clear
	docker compose exec php php artisan route:clear
	docker compose exec php php artisan view:clear

# Накатить миграции
.PHONY: migrate
migrate: ## Выполнить миграции Laravel
	@echo '${GREEN}Накатываем миграции...${RESET}'
	docker compose exec php php artisan migrate

# Откатить миграции
.PHONY: rollback
rollback: ## Выполнить миграции Laravel
	@echo '${GREEN}Откатываем миграции...${RESET}'
	docker compose exec php php artisan migrate:rollback

