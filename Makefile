# Makefile

# Colors
GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
RESET  := $(shell tput -Txterm sgr0)

# The path to the current Makefile
MAKEFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))

# Help
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

# Start containers
.PHONY: up
up: ## Start containers
	@echo "${GREEN}Creating the src folder, if it doesn't exist...${RESET}"
		mkdir -p src
	@echo '${GREEN}Launching containers...${RESET}'
		docker compose up -d

# Stop containers
.PHONY: down
down: ## Stop containers
	@echo '${GREEN}Stopping containers...${RESET}'
		docker compose down

# Rebuilding
.PHONY: build
build: ## Rebuilding
	@echo "${GREEN}Creating the src folder (if it doesn't exist)...${RESET}"
		mkdir -p src
	@echo '${GREEN}Rebuilding'
		docker compose up -d --build

# Bash in a PHP container
.PHONY: bash
bash: ## Run bash inside a PHP container
	@echo '${GREEN}Launching bash inside a PHP container...${RESET}'
		docker compose exec php bash

# Bash in a PHP container as root
.PHONY: bash-root
bash-root: ## Run bash as root inside a PHP container
	@echo '${GREEN}Launching bash as root inside a PHP container...${RESET}'
		docker compose exec -u root php bash

# Install laravel. The latest version is installed by default.
# To install a specific version, you need to pass the "version" argument. 
# Ex: "make laravel-install version = 10.0".
.PHONY: laravel-install
laravel-install: ## Install laravel (latest version by default)
	@echo '${GREEN}Installing laravel...${RESET}'
ifeq ($(version),)
	docker compose exec php composer create-project laravel/laravel . --no-scripts
else
	docker compose exec php composer create-project "laravel/laravel:^$(version)" . --no-scripts
endif

# Install composer dependencies
.PHONY: composer-install
composer-install: ## Install composer dependencies
	@echo '${GREEN}Installing composer dependencies...${RESET}'
		docker compose exec php composer install --optimize-autoloader --prefer-dist --no-dev

# Copy the .env file and configure session driver & DB drivers
.PHONY: env-copy
env-copy: ##  Copy .env.example to .env and set SESSION_DRIVER=file, DB_CONNECTION=mysql
	@echo '${GREEN}Copying .env file and configuring drivers...${RESET}'
			docker compose exec php sh -c "cp .env.example .env && sed -i 's/SESSION_DRIVER=database/SESSION_DRIVER=file/g; s/DB_CONNECTION=sqlite/DB_CONNECTION=mysql/g' .env"
			
# Generating a laravel key
.PHONY: key-generate
key-generate: ## Generating a laravel key
	@echo '${GREEN}Key generation...${RESET}'
		docker compose exec php php artisan key:generate

# Initiates a simple php project
.PHONY: init
init: ## Initiates a simple php project
	@echo 'Initiates a simple php project...'
		docker compose exec php sh -c "mkdir -p app"
		docker compose exec php sh -c "mkdir -p public"
		docker compose exec php sh -c 'echo "<?php\n\nrequire_once __DIR__ . \"/../vendor/autoload.php\";\n\necho \"Hello World!\";" > public/index.php'
		docker compose exec php sh -c 'echo "{\
		\"name\": \"my/project\",\
		\"description\": \"Simple PHP app with autoloading\",\
		\"type\": \"project\",\
		\"require\": {},\
		\"autoload\": {\
		\"psr-4\": {\
		\"App\\\\\\\\\": \"app/\"\
		}\
		}\
		}" > composer.json'
			docker compose exec php composer install --working-dir=/var/www/html