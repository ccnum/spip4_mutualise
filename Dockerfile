# TODO Prendre une image plus légère si possible.
# TODO ajouter un php.ini ?
# TODO s'assurer de formats supplémentaires acceptés (liste ici https://www.spip.net/fr_article4352.html) comme av1 ou avif, docx...
# TODO joindre une image adminer ou phpmyadmin
# TODO Migrer les données de plugin.xml vers paquet.xml (dans le module CAS)
FROM php:8.1-apache

ENV SPIP_URL="https://files.spip.net/spip/archives/spip-v4.1.5.zip"
ENV SPIP_ZIPFILENAME="spip-v4.1.5.zip"
ENV LISTE_CCN="bd.laclasse.com petitfablab.laclasse.com"
ENV JQUERYUI_URL = "https://files.spip.org/core/jquery_ui-8a3b8-v1.15.2.zip"

# Récupérer un php.ini pour le mode de production.
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
# Extension(s) PHP et dépendances.
RUN apt-get update -y && apt-get upgrade -y && apt-get install unzip libzip-dev zip wget \
                    default-mysql-client \
                    libpng-dev libfreetype6-dev libjpeg62-turbo-dev zlib1g-dev libwebp-dev libxpm-dev libmagickwand-dev imagemagick libmagickcore-dev \
                    git nano -y  && \
    mkdir -p /usr/src/php/ext/imagick && \
    curl -fsSL https://github.com/Imagick/imagick/archive/06116aa24b76edaf6b1693198f79e6c295eda8a9.tar.gz | tar xvz -C "/usr/src/php/ext/imagick" --strip 1 && \
    docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp && \
    docker-php-ext-install mysqli zip pdo_mysql imagick && \
    docker-php-ext-install -j$(nproc) gd && \
    /etc/init.d/apache2 restart

# Récupérer SPIP
ADD $SPIP_URL /var/www/html/
# Préparer SPIP
RUN unzip /var/www/html/$SPIP_ZIPFILENAME -d /var/www/html/ && rm /var/www/html/$SPIP_ZIPFILENAME && mkdir -p /var/www/html/sites/ && mkdir -p /var/www/html/plugins/auto && chown -R www-data:www-data config/ IMG/ local/ plugins/ sites/ tmp/
# Diverses actions préparatoires.
COPY --chown=www-data ./src/shell_actions.sh /var/www/html/config
RUN sh /var/www/html/config/shell_actions.sh && \
# Télécharement du module des CCN avec sa dépendance CAS.
    git clone --branch dev-pierre-alexandre https://github.com/ccnum/plugin_thematique_laclasse.git /var/www/html/plugins/ccn_thematique && \
    git clone --branch cicas-spip4 https://github.com/ccnum/plugin_cas_thematique_laclasse.git /var/www/html/plugins/ccn_thematique_cas
# Configurer SPIP
COPY --chown=www-data ./src/mes_options.php /var/www/html/config


EXPOSE 80