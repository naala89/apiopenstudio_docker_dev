Docker setup for ApiOpenStudio
==============================

This is a setup designed for developers local environments.
It mounts to code inside the container volumes, 
allowing the programmer to edit the code directly and immediately see the results.
It is design to maintain a persistent database, provides an email container for full
end-to-end testing, and optionally serves the wiki and phpdoc.

Note:

* To see changes in the wiki or phpdoc,
  you will need to re-run the dockers to compile them.
* To see styling changes in admin, you will need to either re-run the containers
  (to re-run gulp) or run gulp on the host machine (admin codebase only).
  
There are additional containers for node and composer, for convenience.
This means you will not need to install ```composer```, ```node``` or ```npm```
on the host machine.

Setup
-----

### Clone the code bases

    cd /my/development/directory
    git clone git@gitlab.com:john89/api_open_studio.git
    git clone git@gitlab.com:john89/api_open_studio_admin.git

### Setup SSL certificates

#### Mac

    brew install mkcert nss
    mkcert -install
    cd /my/development/directory/api_open_studio_docker
    mkdir certs
    cd certs
    mkcert -cert-file apiopenstudio.local.crt -key-file apiopenstudio.local.key "*.apiopenstudio.local"
    cp "$(mkcert -CAROOT)/rootCA.pem" ca.crt

### Set up the domains

Configure the ```/etc/hosts``` for your domains.
Add the following lines to your ```hosts``` file:

    127.0.0.1      admin.apiopenstudio.local
    127.0.0.1      api.apiopenstudio.local

### Configure .env

    cp example.env .env

Edit ```.env```:

* APP_NAME
    * The name of you application.
* WITH_XDEBUG (true / false)
    * Build the PHP container with xdebug enabled.
* API_CODEBASE
    * Full path to the API code on your host machine,
      e.g. ```/my/development/directory/api_open_studio```.
* API_DOMAIN
    * The domain of your API
* ADMIN_CODEBASE
    * Full path to the admin site code on your host machine,
      e.g. ```/my/development/directory/api_open_studio_admin```.
* ADMIN_DOMAIN
    * The domain of your admin site.
* WIKI_DOMAIN
    * (optional) The domain of the wiki site if you want to host it.
* PHPDOC_DOMAIN
    * (optional) The domain of the phpdoc site if you want to host it.
* MYSQL_HOST
    * The host of the Database.
* MYSQL_DATABASE
    * The name of the database.
* MYSQL_USER
    * The database user.
* MYSQL_PASSWORD
    * The password for the database user.
* EMAIL_USERNAME
    * The username for the amil container.
* EMAIL_PASSWORD
    * The password for the amil container.

Serve thw wiki locally (optional)
---------------------------------

Add the following line to ```/etc/hosts```:

    127.0.0.1      wiki.apiopenstudio.local

Uncomment the following line from ```.env```

    WIKI_DOMAIN=wiki.apiopenstudio.local

Uncomment the wiki containers in ```docker-compose.yml```:

* bookdown
* wiki

Serve thw phpdoc locally (optional)
-----------------------------------

Add the following line to ```/etc/hosts```:

    127.0.0.1      phpdoc.apiopenstudio.local

Uncomment the following line from ```.env```

    PHPDOC_DOMAIN=phpdoc.apiopenstudio.local

Uncomment the wiki containers in ```docker-compose.yml```:

* phpdocumentor
* phpdoc

Logs
----

The API, admin and php containers are configured to display the server logs in
this docker directory:

    ./logs/admin/
    ./logs/api/
    ./logs/php/

Running the docker
------------------

### Start

    docker-composer up -d

### Stop

    docker-composer down
