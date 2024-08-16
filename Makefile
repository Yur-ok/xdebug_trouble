SHELL = sh
.EXPORT_ALL_VARIABLES:
.ONESHELL:

CURRENT_UID:=$(shell id -u)
CURRENT_GID:=$(shell id -g)
CURRENT_DIR:=$(shell pwd)
DE=docker exec
DC=docker compose
run:=install

default: start

composer:
	docker run --rm \
        -u $(CURRENT_UID):$(CURRENT_GID) \
        -v $(CURRENT_DIR)/app:/var/www/html \
        -w /var/www/html laravelsail/php82-composer:latest \
        composer ${run}
build: touch-local-env # Собрать сервис
	${DC} --env-file app/.env --env-file app/.env.local build
start: touch-local-env ## Запустить сервис
	${DC} --env-file app/.env --env-file app/.env.local up --force-recreate -d
	${DE} local-app php -v
stop: ## Остановить сервис
	${DC} stop
restart: 
	${DC} restart
cli: ## Перейти в контейнер
	${DE} -it --env-file app/.env --env-file app/.env.local local-app bash
db-create: # Создать бд
	${DE} -it local-pgsql bash -c "psql -U \$$DB_USERNAME -d postgres -c \"\
	CREATE DATABASE \$$DB_DATABASE \
	WITH OWNER = \$$DB_USERNAME \
	ENCODING 'UTF-8' \
	TABLESPACE = pg_default \
	LC_COLLATE = 'ru_RU.UTF-8' \
	LC_CTYPE = 'ru_RU.UTF-8' \
	CONNECTION LIMIT = -1 \
	TEMPLATE = template0;\""

