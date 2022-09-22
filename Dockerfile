ENV SPIP_URL "https://files.spip.net/spip/archives/spip-v4.1.5.zip"

# Prendre une image plus légère si possible.
FROM php:8-apache

# Extension(s) PHP.
RUN docker-php-ext-install mysqli

# Récupérer SPIP
RUN wget $SPIP_URL


EXPOSE 80