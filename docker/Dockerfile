# Utiliser PHP 8.3 avec Apache2
FROM php:8.3-apache

# Installer l'extension permettant à PHP de communiquer avec MariaDB
RUN docker-php-ext-install pdo_mysql

# Indiquer que le site se trouve dans le dossier public
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public

# Configurer Apache pour utiliser ce dossier
RUN sed -ri 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' \
    /etc/apache2/sites-available/*.conf \
    /etc/apache2/apache2.conf \
    /etc/apache2/conf-available/*.conf