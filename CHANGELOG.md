ApiOpenStudio Docker v1.0.0
===========================

- Shared PHP container.
- Container to maintain a persistent DB.
- NGINX containers for:
    - API.
    - Admin.
    - Wiki.
    - PHPDoc.
- Serve the multiple domains through an NGINX reverse proxy.
- Container to render the wiki.
- Container to render the PHPDoc.
- Container to install the Composer dependencies.
- Container to install the npm dependencies and run gulp.
- Container for email configuration.
- Code mounted into a volume to allow live development.
- Mount the logs into the hosting environment.
- Persistent DB.
