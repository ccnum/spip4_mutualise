# Prendre une image plus légère si possible.
FROM php:8-apache

ENV SPIP_URL="https://files.spip.net/spip/archives/spip-v4.1.5.zip"
ENV SPIP_ZIPFILENAME="spip-v4.1.5.zip"

# Extension(s) PHP.
RUN docker-php-ext-install mysqli && apt-get update -y && apt-get install unzip -y

# Récupérer SPIP
ADD $SPIP_URL /var/www/html/
RUN unzip /var/www/html/$SPIP_ZIPFILENAME -d /var/www/html/

EXPOSE 80