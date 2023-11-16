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
	make composer
	make build
	docker run --rm -v "$${ADMIN_CODEBASE}:/app" "apiopenstudio_docker_dev-$${ADMIN_SUBDOMAIN}" yarn install
	docker compose run --rm -it php ./bin/aos-install
	docker compose down db

## up	: Build & spin up the docker containers.
##		Command: make up
.PHONY: up
up:
	if [ -d "./logs/apiopenstudio" ]; then\
		rm -R "./logs/apiopenstudio";\
	fi
	if [ -d "./logs/traefik" ]; then\
		rm -R "./logs/traefik";\
	fi
	docker compose up -d
	make yarn serve

## down	: Stop and remove all containers.
##		Command: make down
.PHONY: down
down:
	docker compose down

## stop	: Stop all containers, but do not delete them.
##		Command: make stop
.PHONY: stop
stop:
	docker compose stop

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

	if [[ $${MAKE_ARGS} = "install" && -d "$${ADMIN_CODEBASE}/node_modules" ]]; then\
		rm -R "$${ADMIN_CODEBASE}/node_modules";\
	fi
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

## build	: build all the images.
##		Command: make build
.PHONY: build
build:
	docker compose build

## certs	: generate the SSL certificates.
##		Command: make certs
.PHONY: certs
certs:
	mkcert "$${API_SUBDOMAIN}.$${DOMAIN}" "$${ADMIN_SUBDOMAIN}.$${DOMAIN}" "*.$${DOMAIN}" localhost 127.0.0.1 ::1
	mv *.pem config/certs/

# https://stackoverflow.com/a/6273809/1826109
%:
	@:
