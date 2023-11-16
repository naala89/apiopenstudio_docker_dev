Docker Dev setup for ApiOpenStudio
==================================

This is a local environment setup for developers of ApiOpenStudio core and
admin. It mounts to code inside the container volumes, allowing the programmer
to edit the code directly and immediately see the results. It is designed to
maintain a persistent database, provides an email container for full end-to-end
testing, and serves the phpdoc.

**Note:** To see changes in the phpdoc, you will need to re-run the dockers to compile
  them.

The containers are completely encapsulated, which means you will not need to install
`composer`, `node` or `vue` on the host machine. By default, the configuration
is set up to the latest PHP version (currently 8.2). See the FAQ to run
ApiOpenStudio on a different version.

# Setup

## Clone the code bases

    cd /my/development/directory
    git clone git@gitlab.com:apiopenstudio/apiopenstudio.git
    git clone git@gitlab.com:apiopenstudio/apiopenstudio_admin_vue.git
    git clone git@gitlab.com:apiopenstudio/apiopenstudio_docker_dev.git

## Configure ApiOpenStudio core

    cd apiopenstudio
    cp example.docker-dev.settings.yml settings.yml

## Configure Traefik

    cd apiopenstudio_docker_dev
    cp example.env .env

Update the values for `API_CODEBASE` and `ADMIN_CODEBASE` in `.env` so that
they point to your repository clones.

## Configure the `hosts` file

Update `/etc/hosts` to contain the following values:

    127.0.0.1       admin.apiopenstudio.local
    127.0.0.1       api.apiopenstudio.local
    127.0.0.1       phpdoc.apiopenstudio.local
    127.0.0.1       traefik.apiopenstudio.local
    127.0.0.1       localhost


## Set up the DB and all dependencies

    cd apiopenstudio_docker_dev
    make setup

In the final step of the setup, you will be asked to answer several questions
for the initial database setup:

    Continuing will create a new database and erase the current database, if it exists, continue [Y/n]:
    ...

    Include test users and accounts [y/N]:
    ...

    Enter the admin users username:
    Enter the admin users password:
    Enter the admin users email:
    ...

    Automatically generate public/private keys for JWT (WARNING: this will overwrite any existing keys at the location defined in settings.yml) [Y/n]:
    ...

    ApiOpenStudio is successfully installed!
    You will now be able to configure and use the admin GUI and/or make REST calls to Api OpenStudio.

# Running the docker

## Start

    make up

## Stop

    make down

# URLs

* [Admin][local_admin]
* [API][local_api]
* [Traefik][local_traefik]
* [PHPDoc][local_phpdoc]

# Logs

The API, admin and php containers are configured to display the server logs in
this docker directory:

    logs/apiopenstudio/
        db.log
        api.log
    logs/traefik/
        error.log
        access.log

# FAQ

## Will I lose any data when I stop or delete the containers?

No. The database is stored in a docker volume:
`apiopenstudio_docker_dev_dbdata`. This will persist, unless you expressly
delete the volume or re-run `make setup`.

## I get `Your Composer dependencies require a PHP version ">= 8.2.0".`

This usually occurs when you are running when the `composer` image is a mismatch
for the PHP version you are using.

After updating the `.env` and `docker-compose.yml` files, run:

    make composer

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

## What are all the `Makefile` commands?

* `make help`
  * List all `make` commands.
* `make setup`
  * install and configure all requirements, based on the `.env` files.
* `make up`
  * Spin up the docker containers for ApiOpenStudio.
* `make down`
  * Spin down the docker containers for ApiOpenStudio and delete them.
* `make stop`
  * Spin down the docker containers for ApiOpenStudio but do not delete them.
* `make yarn <command>`
  * Run a yarn command in the `admin` container (requires the admin container
    to be running).
* `make composer`
  * Run a yarn command in the `admin` container.
    to be running).
* `make logs <container>`
  * View the logs that a container outputs to `stdout`
* `make build`
  * Build all containers.
* `make certs`
  * Generate the SSL certificates for the proxy entrypoint.

[local_traefik]: https://admin.apiopenstudio.local:8080
[local_api]: https://api.apiopenstudio.local
[local_phpdoc]: https://phpdoc.apiopenstudio.local
[local_admin]: https://admin.apiopenstudio.local
