# Prendre une image plus légère si possible.
FROM php:8-apache

ENV SPIP_URL="https://files.spip.net/spip/archives/spip-v4.1.5.zip"

# Extension(s) PHP.
RUN docker-php-ext-install mysqli

# Récupérer SPIP
ADD $SPIP_URL /var/www/html/


EXPOSE 80