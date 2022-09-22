# Prendre une image plus légère si possible.
FROM php:8-apache

ENV SPIP_URL="https://files.spip.net/spip/archives/spip-v4.1.5.zip"
ENV SPIP_ZIPFILENAME="spip-v4.1.5.zip"

# Extension(s) PHP et dépendances.
RUN apt-get update -y && \
    apt-get install unzip libzip-dev zip default-mysql-client -y &&\
    docker-php-ext-install mysqli && \
    docker-php-ext-install zip && \
    /etc/init.d/apache2 restart

# Récupérer SPIP / Préparer SPIP
ADD $SPIP_URL /var/www/html/
RUN unzip /var/www/html/$SPIP_ZIPFILENAME -d /var/www/html/ && \
    rm /var/www/html/$SPIP_ZIPFILENAME && \
    mkdir -p sites/petitfablab.laclasse.com/IMG && \
    mkdir -p sites/petitfablab.laclasse.com/tmp && \
    mkdir -p sites/petitfablab.laclasse.com/local && \
    mkdir -p sites/petitfablab.laclasse.com/config &&\
    chown -R www-data sites/

COPY --chown=www-data ./src/mes_options.php /var/www/html/config/

EXPOSE 80