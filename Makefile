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

#**********************************
# Setup and initialisation commands
#**********************************

## setup: Install the certificates, install all dependencies and build the docker images
##		Command: make setup
.PHONY: setup
setup:
	make certs
	make composer
	make build
	docker run --rm -v "$${ADMIN_CODEBASE}:/app" "apiopenstudio_docker_dev-$${ADMIN_SUBDOMAIN}" yarn install

## init: Initialise the DB
##		Command: make init
.PHONY: init
init:
	docker compose run --rm -it php ./bin/aos-install

#**********************
# Spin up/down commands
#**********************

## up	: Build & spin up the docker containers.
##		Command: make up
.PHONY: up
up:
	if [ -d "./logs/apiopenstudio" ]; then rm -R "./logs/apiopenstudio"; fi
	if [ -d "./logs/traefik" ]; then rm -R "./logs/traefik"; fi
	if [ -d "./logs/nginx" ]; then rm -R "./logs/nginx"; fi
	docker compose up -d

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

#********************
# Styleguide commands
#********************

## styleguide	: Start the styleguide
##		Command: make styleguide
.PHONY: styleguide
styleguide:
	docker exec -t "$${APP_NAME}-$${STYLEGUIDE_SUBDOMAIN}" yarn storybook

## styleguide-build	: Build the styleguide
##		Command: make styleguide-build
.PHONY: styleguide-build
styleguide-build:
	docker exec -t "$${APP_NAME}-$${STYLEGUIDE_SUBDOMAIN}" yarn build-storybook

#*****************
# Testing commands
#*****************

## test-fe	: Run all frontend tests
##		Command: make test-fe
.PHONY: test-fe
test-fe:
	make test-fe-lint
	make test-fe-unit
	make test-fe-component
	# make test-fe-e2e # NOT WORKING YET
	make test-fe-coverage

## test-be	: Run all backend tests  (untested, undocumented and limited to PHP8.1 ATM)
##		Command: make test-be
.PHONY: test-be
test-be:
	make test-be-unit
	make test-be-api

## test-fe-lint	: Run frontend lint tests. Test results are in <apiopenstudio_admin_vue>/tests/reports/lint-test-results.{html,xml}
##		Command: make test-fe-lint
.PHONY: test-fe-lint
test-fe-lint:
	docker exec -t "$${APP_NAME}-$${ADMIN_SUBDOMAIN}" yarn ci:lint

## test-fe-unit	: Run frontend unit tests. Test results are in <apiopenstudio_admin_vue>/tests/reports/unit-test-results.{html,xml}
##		Command: make test-fe-unit
.PHONY: test-fe-unit
test-fe-unit:
	docker exec -t "$${APP_NAME}-$${ADMIN_SUBDOMAIN}" yarn ci:unit

## test-fe-component	: Run frontend component tests. Test results are in <apiopenstudio_admin_vue>/tests/reports/component-test-results.{html,json}
##		Command: make test-fe-component
.PHONY: test-fe-component
test-fe-component:
	docker run --rm -it --name "$${APP_NAME}-cypress" -v "$${ADMIN_CODEBASE}:/component" -w /component --entrypoint=cypress $${CYPRESS_IMAGE} run --component --config-file cypress.config.js

# test-fe-e2e	: Run frontend e2e tests. Test results are in <apiopenstudio_admin_vue>/tests/reports/e2e-test-results.{html,json}. # NOT WORKING YET
#		Command: make test-fe-e2e
#.PHONY: test-fe-e2e
#test-fe-e2e:
#	docker run --rm -it --name "$${APP_NAME}-cypress" -v "$${ADMIN_CODEBASE}:/e2e" -w /e2e --entrypoint=cypress $${CYPRESS_IMAGE} run --e2e --config-file cypress.config.js

## test-fe-coverage	: Run frontend coverage tests. Test results are in <apiopenstudio_admin_vue>/tests/reports/coverage/index.html
##		Command: make test-fe-coverage
.PHONY: test-fe-coverage
test-fe-coverage:
	docker exec -t "$${APP_NAME}-$${ADMIN_SUBDOMAIN}" bash -c "vitest run --coverage -c vitest.config.ci.mjs"

## test-be-unit	: Run backend unit tests (untested, undocumented and limited to PHP8.1 ATM)
##		Command: make test-be-unit
.PHONY: test-be-unit
test-be-unit:
	docker container run --rm -v "$${API_CODEBASE}:/project" --user $(id -u):$(id -g) codeception/codeception:latest bootstrap
	docker container run --rm -v "$${API_CODEBASE}:/project" --user $(id -u):$(id -g) codeception/codeception:latest --env ci unit

## test-be-api	: Run backend api tests (untested, undocumented and limited to PHP8.1 ATM)
##		Command: make test-be-api
.PHONY: test-be-api
test-be-api:
	docker container run --rm -v "$${API_CODEBASE}:/project" --user $(id -u):$(id -g) codeception/codeception:latest bootstrap
	docker container run --rm -v "$${API_CODEBASE}:/project" --user $(id -u):$(id -g) codeception/codeception:latest --env ci api

#**********************
# Utility task commands
#**********************

## yarn: Run a yarn command in the admin container.
##		Command: make yarn install
##		Command: make yarn up
##		Command: make yarn down
.PHONY: yarn
yarn:
	if [[ $${MAKE_ARGS} = "install" && -d "$${ADMIN_CODEBASE}/node_modules" ]]; then\
		rm -R "$${ADMIN_CODEBASE}/node_modules";\
	fi
	docker exec -t "$${APP_NAME}-$${ADMIN_SUBDOMAIN}" yarn $${MAKE_ARGS}

## flush-redis: Flush all Redis cache.
##		Command: make flush-redis
.PHONY: flush-redis
flush-redis:
	docker exec -i "$${APP_NAME}-redis" redis-cli FLUSHALL

## composer: Refresh the composer dependencies.
##		Command: make composer
.PHONY: composer
composer:
	if [ -f "$${API_CODEBASE}/composer.lock" ]; then rm "$${API_CODEBASE}/composer.lock"; fi
	if [ -d "$${API_CODEBASE}/vendor" ]; then rm -R "$${API_CODEBASE}/vendor"; fi
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
	if [ -f ./config/certs/*key.pem ]; then rm ./config/certs/*key.pem; fi
	if [ -f ./config/certs/*.pem ]; then rm ./config/certs/*.pem; fi
	mkcert "$${STYLEGUIDE_SUBDOMAIN}.$${DOMAIN}" "$${API_SUBDOMAIN}.$${DOMAIN}" "$${ADMIN_SUBDOMAIN}.$${DOMAIN}" "*.$${DOMAIN}" localhost 127.0.0.1 ::1
	mv ./*key.pem ./config/certs/apiopenstudio.local-key.pem
	mv ./*.pem ./config/certs/apiopenstudio.local.pem

# https://stackoverflow.com/a/6273809/1826109
%:
	@:
