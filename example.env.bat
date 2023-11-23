rem Example env.bat file.
rem
rem @package   Apiopenstudio
rem @license   This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
rem            If a copy of the MPL was not distributed with this file,
rem            You can obtain one at https://mozilla.org/MPL/2.0/.
rem @author    john89 (https://gitlab.com/john89)
rem @copyright 2020-2030 Naala Pty Ltd
rem @link      https://www.apiopenstudio.com

rem General
set APP_NAME=apiopenstudio
set DOMAIN=apiopenstudio.local
set SSL_CERT_DIR=./config/certs
set PHP_VERSION=8.2
set TRAEFIK_VERSION=2.10

rem Proxy
set PROXY_SUBDOMAIN=traefik

rem Database
set MYSQL_HOST=apiopenstudio-db
set MYSQL_DATABASE=apiopenstudio
set MYSQL_USER=apiopenstudio
set MYSQL_PASSWORD=apiopenstudio
set MYSQL_ROOT_PASSWORD=apiopenstudio

rem API
set API_CODEBASE=C:\path\to\apiopenstudio
set API_SUBDOMAIN=api
set WITH_XDEBUG=false
set WITH_MEMCACHED=false
set WITH_REDIS=false

rem Admin
set ADMIN_CODEBASE=C:\path\to\apiopenstudio_admin_vue
set ADMIN_SUBDOMAIN=admin

rem PHPDoc
set PHPDOC_SUBDOMAIN=phpdoc
