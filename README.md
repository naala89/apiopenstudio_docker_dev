Docker Dev setup for ApiOpenStudio
==================================

This is a setup designed for developers local environments. It mounts to code
inside the container volumes, allowing the programmer to edit the code directly
and immediately see the results. It is design to maintain a persistent
database, provides an email container for full end-to-end testing, and
optionally serves the phpdoc.

Note:

* To see changes in the wiki or phpdoc, you will need to re-run the dockers to
  compile them.
* To see styling changes in admin, you will need to either re-run the
  containers (to re-run gulp) or run gulp on the host machine (admin codebase
  only).

There are additional containers for node and composer, for convenience. This
means you will not need to install `composer`, `node` or `npm` on the host
machine.

# Setup

## New install

Clone the code bases

    cd /my/development/directory
    git clone git@gitlab.com:apiopenstudio/apiopenstudio.git
    git clone git@gitlab.com:apiopenstudio/apiopenstudio_admin.git
    git clone git@gitlab.com:apiopenstudio/apiopenstudio_docker_dev.git

    cd apiopenstudio
    cp example.docker-dev.settings.yml settings.yml

    cd ../apiopenstudio_docker_dev
    cp example.env .env

Configure the `.env` file.

    make install
    make up
    docker exec -it apiopenstudio-php bash
    ./bin/aos-install

add to `/etc/hosts`

    127.0.0.1 apiopenstudio.local

## Clone the code bases

    cd /my/development/directory
    git clone git@gitlab.com:apiopenstudio/apiopenstudio.git
    git clone git@gitlab.com:apiopenstudio/apiopenstudio_admin.git
    git clone git@gitlab.com:apiopenstudio/apiopenstudio_docker_dev.git

## Setup SSL certificates

### Mac

    brew install mkcert nss
    mkcert -install
    cd /my/development/directory/apiopenstudio_docker_dev
    mkdir certs
    cd certs
    mkcert -cert-file apiopenstudio.local.crt -key-file apiopenstudio.local.key "*.apiopenstudio.local"
    cp "$(mkcert -CAROOT)/rootCA.pem" ca.crt

## Set up the domains

Configure the `/etc/hosts` for your domains. Add the following lines to your
`hosts` file:

    127.0.0.1 admin.apiopenstudio.local
    127.0.0.1 api.apiopenstudio.local

## Configure .env

    cp example.env .env

Edit `.env`:

* `APP_NAME` = The name of you application.
* `PHP_VERSION` (7.4, 8.0, 8.1)
    * Select the PHP version for the server.
    * **NOTE**: ensure you are using the correct composer image in
      `docker-compose.yml`
* `WITH_XDEBUG` (true / false) - Build the PHP container with xDebug enabled.
* `WITH_MEMCACHED` (true / false) - Build the PHP container with Memcached
  enabled.
* `WITH_REDIS` (true / false) - Build the PHP container with Redis enabled.
* `API_CODEBASE` - Full path to the API code on your host machine, e.g.
  `/my/development/directory/apiopenstudio`.
* `API_DOMAIN` - The domain of your API
* `ADMIN_CODEBASE` - Full path to the admin site code on your host machine,
  e.g. `/my/development/directory/apiopenstudio_admin`.
* `ADMIN_DOMAIN` - The domain of your admin site.
* `PHPDOC_DOMAIN` - (optional) The domain of the phpdoc site if you want to
  host it.
* `MYSQL_HOST` - The host of the Database.
* `MYSQL_DATABASE` - The name of the database.
* `MYSQL_USER` - The database user.
* `MYSQL_PASSWORD` - The password for the database user.

# Serve the phpdoc locally (optional)

Add the following line to `/etc/hosts`:

    127.0.0.1 phpdoc.apiopenstudio.local

Uncomment the following line from `.env`

    PHPDOC_DOMAIN=phpdoc.apiopenstudio.local

Uncomment the phpdoc containers in `docker-compose.yml`:

* phpdocumentor
* phpdoc

# Running the docker

## Start

    docker-composer up -d

## Stop

    docker-composer down

# Installation script

Because the DB will not be available outside the docker network, you will
need to run the install script from within the API docker:

    docker exec -it apiopenstudio-php bash
    cd api/
    ./bin/aos-install

# Logs

The API, admin and php containers are configured to display the server logs in
this docker directory:

    ./logs/admin/
    ./logs/api/
    ./logs/php/

# FAQ

## I get `Your Composer dependencies require a PHP version ">= 8.1.0".`

This usually occurs when you are running when the composer image is a mismatch
for the PHP version you are using.

### PHP 8.0

In `.env`:

    PHP_VERSION=8.0

In `docker-compose.yml` file:

    composer:
        image: composer:2.1.11

### PHP 8.1

In `.env`:

    PHP_VERSION=8.1

In `docker-compose.yml` file:

    composer:
        image: composer:latest

### PHP 8.2

In `.env`:

    PHP_VERSION=8.2

In `docker-compose.yml` file:

    composer:
        image: composer:latest

## How do I change PHP environments?

You will need to delete the `composer.lock` file and `vendor/` directory from
your local ApiOpenStudio instance. and restart your containers with:

    docker-compose down
    docker-compose up --build
