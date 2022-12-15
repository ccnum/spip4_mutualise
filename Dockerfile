# Prendre une image plus légère si possible.
FROM php:8-apache

ENV SPIP_URL="https://files.spip.net/spip/archives/spip-v4.1.5.zip"
ENV SPIP_ZIPFILENAME="spip-v4.1.5.zip"

# Extension(s) PHP et dépendances.
RUN apt-get update -y && \
    apt-get install unzip libzip-dev zip \
                    default-mysql-client \
                    libpng-dev libfreetype6-dev libjpeg62-turbo-dev zlib1g-dev libwebp-dev libxpm-dev libmagickwand-dev imagemagick libmagickcore-dev php8.0-imagick \
                    git nano -y && \
    docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp &&\
    docker-php-ext-install mysqli zip pdo_mysql && \
    docker-php-ext-install -j$(nproc) gd &&\
    /etc/init.d/apache2 restart

# Récupérer SPIP
ADD $SPIP_URL /var/www/html/
# Préparer SPIP
RUN unzip /var/www/html/$SPIP_ZIPFILENAME -d /var/www/html/ && rm /var/www/html/$SPIP_ZIPFILENAME && mkdir -p /var/www/html/sites/ && mkdir -p /var/www/html/plugins/auto && chown -R www-data:www-data config/ IMG/ local/ plugins/ sites/ tmp/
# Configurer SPIP
COPY --chown=www-data ./src/mes_options.php /var/www/html/config

EXPOSE 80
