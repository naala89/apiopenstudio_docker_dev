![APIOpenStudio_Logo_Name_Colour.png](img%2FAPIOpenStudio_Logo_Name_Colour.png)
![01-primary-blue-docker-logo.png](img%2F01-primary-blue-docker-logo.png)

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

API and admin requests can be made over HTTP or HTTP, although HTTP is
redirected to HTTPS.

You can access the Traefik (proxy) dashboard on
`http://traefik.apiopenstudio.local:8080`.

Dependencies
============

Git
---

See GitHub's guide for installing Git: [Install Git][install_git]

Docker
------

See [Get Docker](https://docs.docker.com/get-docker/)

Mkcert
------

See the github home page for installing mkcert: [FiloSottile/mkcert][mkcert]

Make (Windows only)
-------------------

```bash
choco install make
```
Setup
=====

Clone the code bases
--------------------

```bash
cd /my/development/directory
git clone git@gitlab.com:apiopenstudio/apiopenstudio.git
git clone git@gitlab.com:apiopenstudio/apiopenstudio_admin_vue.git
git clone git@gitlab.com:apiopenstudio/apiopenstudio_docker_dev.git
```

Configure ApiOpenStudio core
----------------------------

```bash
cd /my/development/directory/apiopenstudio
cp example.docker-dev.settings.yml settings.yml
```

### Windows

```bash
cd /my/development/directory/apiopenstudio
copy example.docker-dev.settings.yml settings.yml
```

Configure Traefik
-----------------

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
copy example.env .env
```

Update the values for `API_CODEBASE` and `ADMIN_CODEBASE` in `env.bat` so that
they point to your repository clones.

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

Configure the `hosts` file
--------------------------

Update `/etc/hosts` (in Windows: `C:\Windows\System32\drivers\etc\hosts`) to
contain the following values:

```txt
127.0.0.1       admin.apiopenstudio.local
127.0.0.1       api.apiopenstudio.local
127.0.0.1       phpdoc.apiopenstudio.local
127.0.0.1       styleguide.apiopenstudio.local
127.0.0.1       traefik.apiopenstudio.local
127.0.0.1       localhost
```

Install all the dependencies and SSL certificates
-------------------------------------------------

```bash
cd /my/development/directory/apiopenstudio_docker_dev
make setup
```

Initialise the database
-----------------------

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

**Important:** Spin down the containers before continuing:

```bash
make down
```

Running the docker
==================

A `Makefile` has been set up in `apiopenstudio_docker_dev` to make things easy.

You can set up, spin up/down, read all logs with the
`apiopenstudio_docker_dev` checkout.

Spin up all the containers
--------------------------

```bash
make up
```

Start the admin service
-----------------------

```bash
make yarn serve
```

**Note:** Yarn will give you the URL's to access it directly in the CLI.
But you should use
[https://admin.apiopenstudio.local](https://admin.apiopenstudio.local)

Spin down all the containers
----------------------------

```bash
make down
```

Running tests
=============

apiopenstudio_admin_vue
-----------------------

**NOTE:** Before running any tests, ensure you have spun up the docker
containers: `make up`.

### Run all tests

Run:

```bash
make test-fe
```

The reports are in:

```txt
apiopenstudio_admin_vue/
├─ tests/
│  ├─ reports/
│  │  ├─coverage/
│  │  │  ├─index.html
│  │  ├─component-test-results.html
│  │  ├─component-test-results.json
│  │  ├─lint-test-results.html
│  │  ├─lint-test-results.xml
│  │  ├─unit-test-results.html
│  │  ├─unit-test-results.xml

```

### Run linting tests only

```bash
make test-fe-lint
```

The reports are in:

```txt
apiopenstudio_admin_vue/
├─ tests/
│  ├─ reports/
│  │  ├─ lint-test-results.html
│  │  ├─ lint-test-results.xml
```

### Run unit tests only

```bash
make test-fe-unit
```

The reports are in:

```txt
apiopenstudio_admin_vue/
├─ tests/
│  ├─ reports/
│  │  ├─ unit-test-results.html
│  │  ├─ unit-test-results.xml
```

### Run component tests only

```bash
make test-fe-component
```

The reports are in:

```txt
apiopenstudio_admin_vue/
├─ tests/
│  ├─ reports/
│  │  ├─ component-test-results.html
│  │  ├─ component-test-results.json
```

### Run e2e tests only

**Note:** These are currently not working

```bash
make test-fe-e2e
```

The reports are in:

```txt
apiopenstudio_admin_vue/
├─ tests/
│  ├─ reports/
│  │  ├─ e2e-test-results.html
│  │  ├─ e2e-test-results.json
```

### Run coverage tests only

```bash
make test-fe-coverage
```

The report is in:

```txt
apiopenstudio_admin_vue/
├─ tests/
│  ├─ reports/
│  │  ├─ coverage/
│  │  │  ├─ index.html
```

URLs
====

* [Admin][local_admin]
* [API][local_api]
* [Traefik][local_traefik]
* [PHPDoc][local_phpdoc]

Logs
====

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

Docker Container Architecture
=============================

![docker_dev architecture.jpg](img%2Fdocker_dev%20architecture.jpg)

The architecture can be split into 3 main regions:

* api (yellow)
* admin (blue)
* phpdoc (red)

As you can see from the dotted connection lines, some containers are optional.
In fact, it is quite possible to run ApiOpenStudio in **headless** mode in
`apiopenstudio_docker_dev` without the admin container running.

Required
--------

* Containers
  * traefik
  * api
  * php
  * composer
  * db
* Docker Volumes
  * db
* Codebase
  * apiopenstudio
  * apiopenstudio_admin_vue

Temporary service containers
----------------------------

* composer
* phpdocumentor

Optional containers
-------------------

* redis
* memcached
* phpdoc
* phpdocumentor
* admin

FAQ
===

Can I bypass Traefik and call the containers directly?
------------------------------------------------------

Yes, the internal network has not been hidden, so you call them directly:

* API: http://<container.ip>:80
* Admin: http://<container.ip>:8081
* PHPDoc: http://<container.ip>:80

## How do I make an API using PostMan?
--------------------------------------

### login

* Method: POST
* URL: https://api.apiopenstudio.local/apiopenstudio/core/auth/token
* Auth: No Auth
* Params: < none >
* Headers:
  * Accept: application/json
* Body (x-www-form-urlencoded):
  * username: <username>
  * passowrd: <password>

### Get applications

* Method: GET
* URL: https://api.apiopenstudio.local/apiopenstudio/core/application
* Auth: Bearer Token
  * Bearer < token >
* Params: < none >
* Headers:
  * Accept: application/json
* Body: < none >

* How do I connect a DB with a client?
--------------------------------------

Create a profile in your favourite DB client using the following settings:

* Host: 127.0.0.1
* Port: 3306
* User: apiopenstudio
* Password: apiopenstudio

How do make a CLI command to the DB?
------------------------------------

You can do this from with the `php` and `db` containers.

### php

```bash
docker exec -it apiopenstudio-php bash
mysql -h db -u apiopenstudio -p
```

Follow the prompt to enter the password

```sql
use apiopenstudio;
```

### db

```bash
docker exec -it apiopenstudio-db bash
mariadb -h 127.0.0.1 -u apiopenstudio -p
```

Follow the prompt to enter the password

```sql
use apiopenstudio;
```

How do I ssh into the containers?
---------------------------------

```bash
docker exec -it <container_name> bash
```

example:

```bash
docker exec -it apiopenstudio-api bash
```

Will I lose any data when I stop or delete the containers?
----------------------------------------------------------

No. The database is stored in a docker volume:
`apiopenstudio_docker_dev_db`. This will persist, unless you expressly
delete the volume or re-run `make setup`.

I get `Access denied for user 'root'@'x.x.x.x' (using password: YES)`
---------------------------------------------------------------------

Check that port 3306 is not being used by another application.

This is probably due to an existing instance of MySQL or MariaDB running or
your host machine or another docker.

You need to ensure that there are no other DB instances running on your host
machine that are using port 3306. 

I get `Your Composer dependencies require a PHP version ">= 8.2.0".`
--------------------------------------------------------------------

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

What are all the `Makefile` commands?
-------------------------------------

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

How do I enable caching?
------------------------

By default, caching is set to off. To turn it on:

### Redis

* Stop the containers: `make down`
* Uncomment the `redis` block in your `docker-compose.yml`
* Update `/my/development/directory/apiopenstudio_docker_dev/.env` (Windows
  update `env.bat`):

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
* Uncomment the `memcached` block in your `docker-compose.yml`
* Update `/my/development/directory/apiopenstudio_docker_dev/.env` (Windows
update `env.bat`):

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

How do I enable PHPDoc?
-----------------------

* Stop the containers: `make down`.
* Uncomment the `phpdocumentor` and `phpdoc` blocks in your
`docker-compose.yml`.
* Start the containers: `make up`.

Make setup hangs during the yarn install phase in Windows
---------------------------------------------------------

This is probably due to memory being too low. However, running the same step in the CLI usually works:

* Delete `node_modules` in `apiopenstudio_admin_vue`
* In `apiopenstudio_docker_dev`, run:

```bash
docker run --rm -v "%ADMIN_CODEBASE%:/app" "apiopenstudio_docker_dev-%ADMIN_SUBDOMAIN%" yarn install
```

[local_traefik]: https://traefik.apiopenstudio.local:8080
[local_api]: https://api.apiopenstudio.local
[local_phpdoc]: https://phpdoc.apiopenstudio.local
[local_admin]: https://admin.apiopenstudio.local
[mkcert]: https://github.com/FiloSottile/mkcert
[install_git]: https://github.com/git-guides/install-git
