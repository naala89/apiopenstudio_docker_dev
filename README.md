Docker Dev setup for ApiOpenStudio
==================================

This is a local environment setup for developers of ApiOpenStudio core and
admin. It mounts to code inside the container volumes, allowing the programmer
to edit the code directly and immediately see the results. It is designed to
maintain a persistent database, provides an email container for full end-to-end
testing, and serves the phpdoc.

The containers are completely encapsulated, which means you will not need to install
`composer`, `node` or `vue` on the host machine. By default, the configuration
is set up to the latest PHP version (currently 8.2). See the FAQ to run
ApiOpenStudio on a different version.

# Dependencies

## Git

See GitHub's guide for installing Git: [Install Git][install_git]

## Docker

See [Get Docker](https://docs.docker.com/get-docker/)

## Mkcert

See the github home page for installing mkcert: [FiloSottile/mkcert][mkcert]

## Make (Windows only)

```bash
choco install make
```
# Setup

## Clone the code bases

```bash
cd /my/development/directory
git clone git@gitlab.com:apiopenstudio/apiopenstudio.git
git clone git@gitlab.com:apiopenstudio/apiopenstudio_admin_vue.git
git clone git@gitlab.com:apiopenstudio/apiopenstudio_docker_dev.git
```

## Configure ApiOpenStudio core

```bash
cd /my/development/directory/apiopenstudio
cp example.docker-dev.settings.yml settings.yml
```

## Configure Traefik

### Mac & Linux

```bash
cd /my/development/directory/apiopenstudio_docker_dev
cp example.env .env
```

Update the values for `API_CODEBASE` and `ADMIN_CODEBASE` in `.env` so that
they point to your repository clones.

### Windows

Replace `Makefile` with `Makfile.windows`

```bash
copy Makefile.windows Makefile
```

Setup the environment variables

```bash
copy example.env.bat env.bat
```

Update the values for `API_CODEBASE` and `ADMIN_CODEBASE` in `env.bat` so that
they point to your repository clones.

```bash
call env.bat
```

#### An escape plan

If anything goes wrong with the environment variables, it is worth exporting
them beforehand, so that you can import and revert to the previous state.

##### Backup

* Open `Registry Editor`.
* Navigate to `Computer\HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment`.
* Export as `system_backup.reg`.
* Navigate to `Computer\HKEY_CURRENT_USER\Environment`.
* Export as `user_backup.reg`.

##### Restore

* Open `Registry Editor`.
* Import the two files.

```bash
cd C:\my\development\directory\apiopenstudio_docker_dev
```

## Configure the `hosts` file

Update `/etc/hosts` (in Windows: `C:\Windows\System32\drivers\etc\hosts`) to
contain the following values:

```txt
127.0.0.1       admin.apiopenstudio.local
127.0.0.1       api.apiopenstudio.local
127.0.0.1       phpdoc.apiopenstudio.local
127.0.0.1       traefik.apiopenstudio.local
127.0.0.1       localhost
```

## Install all the dependencies and SSL certificates

```bash
cd /my/development/directory/apiopenstudio_docker_dev
make setup
```

## Initialise the database

```bash
cd /my/development/directory/apiopenstudio_docker_dev
make up
make init
```

You will be asked to answer several questions for the initial database setup:

```txt
Continuing will create a new database and erase the current database, if it
exists, continue [Y/n]:
...

Include test users and accounts [y/N]:
...

Enter the admin users username:
Enter the admin users password:
Enter the admin users email:
...

Automatically generate public/private keys for JWT (WARNING: this will 
overwrite any existing keys at the location defined in settings.yml) [Y/n]:
...

ApiOpenStudio is successfully installed!
You will now be able to configure and use the admin GUI and/or make REST
calls to Api OpenStudio.
```

Spin down the4 containers:

```bash
make down
```

# Running the docker

A `Makefile` has been set up in `apiopenstudio_docker_dev` to make things easy.

You can set up, spin up/down, read all logs with the
`apiopenstudio_docker_dev` checkout.

## Spin up all the containers

```bash
make up
```

## Start the admin service

```bash
make yarn serve
```

**Note:** Yarn will give you the URL's to access it directly in the CLI.
But you should use
[https://admin.apiopenstudio.local](https://admin.apiopenstudio.local)

## Stop

```bash
make down
```

# URLs

* [Admin][local_admin]
* [API][local_api]
* [Traefik][local_traefik]
* [PHPDoc][local_phpdoc]

# Logs

The API, admin and php containers are configured to display the server logs in
this docker directory:

```txt
apiopenstudio_docker_dev/
├─ logs/
│  ├─ apiopenstudio/
│  │  ├─ db.log
│  │  ├─ api.log
│  ├─ traefik/
│  │  ├─ error.log
│  │  ├─ access.log
```

# FAQ

## Will I lose any data when I stop or delete the containers?

No. The database is stored in a docker volume:
`apiopenstudio_docker_dev_db`. This will persist, unless you expressly
delete the volume or re-run `make setup`.

## I get `Access denied for user 'root'@'x.x.x.x' (using password: YES)`

Check that port 3306 is not being used by another application.

This is probably due to an existing instance of MySQL or MariaDB running or
your host machine or another docker.

You need to ensure that there are no other DB instances running on your host
machine that are using port 3306. 

## I get `Your Composer dependencies require a PHP version ">= 8.2.0".`

This usually occurs when you are running when the `composer` image is a
mismatch for the PHP version you are using.

After updating the `.env` and `docker-compose.yml` files, and then run:

```bash
make composer
```

### PHP 8.0

In `.env`:

```dotenv
PHP_VERSION=8.0
```

In `docker-compose.yml` file:

```yml
composer:
  image: composer:2.1.11
```

Run:

```bash
make composer
```

### PHP 8.1

In `.env`:

```dotenv
PHP_VERSION=8.1
```

In `docker-compose.yml` file:

```yml
composer:
  image: composer:latest
```

Run:

```bash
make composer
```

### PHP 8.2

In `.env`:

```dotenv
PHP_VERSION=8.2
```

In `docker-compose.yml` file:

```yml
composer:
  image: composer:latest
```

Run:

```bash
make composer
```

## What are all the `Makefile` commands?

* `make help`
  * List all `make` commands.
* `make setup`
  * Install the certificates, install all dependencies and build the docker
  images.
* `make init`
  * Initialise the database.
* `make up`
  * Spin up the docker containers for ApiOpenStudio.
* `make down`
  * Spin down the docker containers for ApiOpenStudio and delete them.
* `make stop`
  * Spin down the docker containers for ApiOpenStudio but do not delete them.
* `make yarn <command>`
  * Run a yarn command in the `admin` container (requires the admin container
    to be running).
* `make flush-redis`
  * Flush all redis cache.
* `make composer`
  * Install all composer dependencies.
* `make logs <container>`
  * View the logs that a container outputs to `stdout`
* `make build`
  * Build all containers.
* `make certs`
  * Generate the SSL certificates for the proxy entrypoint.

## How do I enable caching?

By default, caching is set to off. To turn it on:

### Redis

* Stop the containers: `make down`
* Uncomment the `redis` blocks in your `docker-compose.yml`
* Update `/my/development/directory/apiopenstudio_docker_dev/.env`:

```dotenv
WITH_MEMCACHED=false
WITH_REDIS=true
```

* Configure ApiOpenStudio core to use caching, by editing `settings.yml` in
`/my/development/directory/apiopenstudio`:

```yml
cache:
  active: true
  type: redis
  servers:
    host: apiopenstudio-redis
    port: 6379
    password:
```

* Rebuild the containers with: `make build`
* Start the containers: `make up`

### Memcached:

* Stop the containers: `make down`
* Uncomment the `redis` blocks in your `docker-compose.yml`
* Update `/my/development/directory/apiopenstudio_docker_dev/.env`:

```dotenv
WITH_MEMCACHED=true
WITH_REDIS=false
```

* Configure ApiOpenStudio core to use caching, by editing `settings.yml` in
  `/my/development/directory/apiopenstudio`:

```yml
cache:
  active: true
  type: memcached
  servers:
    host: apiopenstudio-memcached
    port: 11211
    weight: 1
```

## How do I enable PHPDoc?

* Stop the containers: `make down`.
* Uncomment the `phpdocumentor` and `phpdoc` blocks in your
`docker-compose.yml`.
* Start the containers: `make up`.

## Make setup hangs during the yarn install phase in Windows

This is probably due to memory being too low. However, running the same step in the CLI usually works:

* Delete `node_modules` in `apiopenstudio_admin_vue`
* In `apiopenstudio_docker_dev`, run:

```bash
docker run --rm -v "%ADMIN_CODEBASE%:/app" "apiopenstudio_docker_dev-%ADMIN_SUBDOMAIN%" yarn install
```

[local_traefik]: https://admin.apiopenstudio.local:8080
[local_api]: https://api.apiopenstudio.local
[local_phpdoc]: https://phpdoc.apiopenstudio.local
[local_admin]: https://admin.apiopenstudio.local
[mkcert]: https://github.com/FiloSottile/mkcert
[install_git]: https://github.com/git-guides/install-git
