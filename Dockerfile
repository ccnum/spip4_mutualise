# Prendre une image plus légère si possible.
FROM php:8-apache

ENV SPIP_URL="https://files.spip.net/spip/archives/spip-v4.1.5.zip"
ENV SPIP_ZIPFILENAME="spip-v4.1.5.zip"

# Extension(s) PHP.
RUN docker-php-ext-install mysqli && \
    apt-get update -y && \
    apt-get install unzip -y

# Récupérer SPIP / Préparer SPIP
ADD $SPIP_URL /var/www/html/
RUN unzip /var/www/html/$SPIP_ZIPFILENAME -d /var/www/html/ && \
    rm /var/www/html/$SPIP_ZIPFILENAME && \
    mkdir -p sites/petitfablab.laclasse.com/IMG && \
    mkdir -p sites/petitfablab.laclasse.com/tmp && \
    mkdir -p sites/petitfablab.laclasse.com/local && \
    mkdir -p sites/petitfablab.laclasse.com/config

COPY ./src/mes_options.php /var/www/html/

EXPOSE 80