ApiOpenStudio Docker
====================

v1.0.0
------

- Shared PHP container.
- Container to maintain a persistent DB.
- NGINX containers for:
    - API.
    - Admin.
    - Wiki.
    - PHPDoc.
- Serve the multiple domains through an NGINX reverse proxy.
- Container to render the PHPDoc.
- Container to install the Composer dependencies.
- Container to install the npm dependencies and run gulp.
- Container for email configuration.
- Code mounted into a volume to allow live development.
- Mount the logs into the hosting environment.
- Persistent DB.

v1.0.1
------

- Deprecated PHP7.4
- Added PHP8.2
- Minor fixes in example.env

v1.0.1
------

- Implemented Traefik
- Added makefile for ease of use
- Updated for use on Linux and Windows
