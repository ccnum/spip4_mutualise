# Prendre une image plus légère si possible.
FROM php:8-apache

ENV SPIP_URL="https://files.spip.net/spip/archives/spip-v4.1.5.zip"
ENV SPIP_ZIPFILENAME="spip-v4.1.5.zip"

# Extension(s) PHP et dépendances.
RUN apt-get update -y && \
    apt-get install unzip libzip-dev zip default-mysql-client libpng-dev git nano -y &&\
    docker-php-ext-install mysqli && \
    docker-php-ext-install zip && \
    docker-php-ext-install gd && \
    docker-php-ext-install pdo pdo_mysql && \
    /etc/init.d/apache2 restart

# Récupérer SPIP
ADD $SPIP_URL /var/www/html/
# Préparer SPIP
RUN unzip /var/www/html/$SPIP_ZIPFILENAME -d /var/www/html/ && rm /var/www/html/$SPIP_ZIPFILENAME && mkdir -p /var/www/html/sites/ && chown -R www-data:www-data config/ IMG/ local/ sites/ tmp/
# Configurer SPIP
COPY --chown=www-data ./src/mes_options.php /var/www/html/config

EXPOSE 80
