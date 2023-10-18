include .env
export

# use extra arguments for commands
MAKE_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
$(eval $(MAKE_ARGS):;@:)

## help	: List all make commands
##		Command: make help
.PHONY: help
help : Makefile
	@sed -n 's/^##//p' $<

## setup: Install the certificates, configure the proxy and API domain, build the docker images
##		Command: make setup
.PHONY: setup
setup:
	make certs
	make proxy_config
	make composer
	make build
	# if [ -d "$${ADMIN_CODEBASE}/node_modules" ]; then\
	# 	rm -R "$${ADMIN_CODEBASE}/node_modules";\
	# fi
	# docker compose run admin
	# make yarn install
	# docker compose down

## up	: Build & spin up the docker containers.
##		Command: make up
.PHONY: up
up:
	docker-compose up -d

## down	: Stop and remove all containers.
##		Command: make down
.PHONY: down
down:
	docker-compose down

## stop	: Stop all containers.
##		Command: make stop
.PHONY: stop
stop:
	docker-compose stop

## yarn: Run a yarn command in the admin container.
##		Command: make yarn install
##		Command: make yarn up
##		Command: make yarn down
##		Command: make yarn lint
##		Command: make yarn unit
##		Command: make yarn component
##		Command: make yarn e2e
##		Command: make yarn coverage
.PHONY: yarn
yarn:
	docker exec -t "$${APP_NAME}-$${ADMIN_SUBDOMAIN}" yarn $${MAKE_ARGS}

## composer: Refresh the composer dependencies.
##		Command: make composer
.PHONY: composer
composer:
	if [ -f "$${API_CODEBASE}/composer.lock" ]; then\
		rm "$${API_CODEBASE}/composer.lock";\
	fi
	if [ -d "$${API_CODEBASE}/vendor" ]; then\
		rm -R "$${API_CODEBASE}/vendor";\
	fi
	docker compose run --rm composer

## logs	: View the logs in a docker container.
##		Command: make logs <container>
##		Examples:
##		  	make logs php
##		  	make logs db
##		  	make logs traefik
##		  	make logs api
##		  	make logs admin
.PHONY: logs
logs:
	docker logs "$${APP_NAME}-$${MAKE_ARGS}"

.PHONY: build
build:
	docker compose build

.PHONY: certs
certs:
	mkcert "*.$${DOMAIN}" localhost 127.0.0.1 ::1
	mv *.pem config/certs/

.PHONY: proxy_config
proxy_config:
	cp config/proxy/dynamic.tpl config/proxy/dynamic.yml
	sed -i -e "s/PROXY_DOMAIN/$${PROXY_SUBDOMAIN}.$${DOMAIN}/g" config/proxy/dynamic.yml
	sed -i -e "s/DOMAIN/$${DOMAIN}/g" config/proxy/dynamic.yml
	rm config/proxy/dynamic.yml-e

# https://stackoverflow.com/a/6273809/1826109
%:
	@:
