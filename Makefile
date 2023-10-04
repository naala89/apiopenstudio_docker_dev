include .env
export

# use extra arguments for commands
MAKE_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
$(eval $(MAKE_ARGS):;@:)

## help		: List all make commands
.PHONY: help
help : Makefile
	@sed -n 's/^##//p' $<

## install	: Install the certificates, configure the proxy and API domain, build the docker images
.PHONY: install
install:
	make certs
	make api_config
	make admin_config
	make phpdoc_config
	make proxy_config
	make proxy_config
	make composer
	make build

## build		: Build all of the custom images. This is not required for local dev testing and will be loomed in to the nightly build process
.PHONY: build
build:
	docker compose build

## composer	: Refresh the composer dependencies.
.PHONY: composer
composer:
	rm -R "$${API_CODEBASE}/composer.lock" "$${API_CODEBASE}/vendor"
	docker compose run --rm composer

## up		: Build & spin up the docker containers.
.PHONY: up
up:
	docker-compose up -d

## down		: Stop and remove all containers.
.PHONY: down
down:
	docker-compose down

## stop		: Stop all containers.
.PHONY: stop
stop:
	docker-compose stop

.PHONY: certs
certs:
	mkcert -cert-file "$${DOMAIN}.crt" -key-file "$${DOMAIN}.key" "*.$${DOMAIN}"
	mv "$${DOMAIN}.crt" config/certs/
	mv "$${DOMAIN}.key" config/certs/
	cp "$$(mkcert -CAROOT)/rootCA.pem" config/certs/ca.crt

.PHONY: api_config
api_config:
	cp config/api/default.tpl config/api/default
	sed -i -e "s/API_DOMAIN/$${API_SUBDOMAIN}.$${DOMAIN}/g" config/api/default
	rm config/api/default-e

.PHONY: admin_config
admin_config:
	cp config/admin/default.tpl config/admin/default
	sed -i -e "s/ADMIN_DOMAIN/$${ADMIN_SUBDOMAIN}.$${DOMAIN}/g" config/admin/default
	rm config/admin/default-e

.PHONY: phpdoc_config
phpdoc_config:
	cp config/phpdoc/default.tpl config/phpdoc/default
	sed -i -e "s/PHPDOC_DOMAIN/$${PHPDOC_SUBDOMAIN}.$${DOMAIN}/g" config/phpdoc/default
	rm config/phpdoc/default-e

.PHONY: proxy_config
proxy_config:
	cp config/proxy/dynamic.tpl config/proxy/dynamic.yml
	sed -i -e "s/PROXY_DOMAIN/$${PROXY_SUBDOMAIN}.$${DOMAIN}/g" config/proxy/dynamic.yml
	sed -i -e "s/DOMAIN/$${DOMAIN}/g" config/proxy/dynamic.yml
	rm config/proxy/dynamic.yml-e

## logs		: View the PHP server logs.
.PHONY: logs
logs:
	docker logs "$${PROJECT}-php"

# https://stackoverflow.com/a/6273809/1826109
%:
	@:
