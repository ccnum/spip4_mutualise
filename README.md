# Dockerisation d'une ferme à SPIP (SPIP4)

[Qu'est-ce que SPIP ?](https://www.spip.net/fr_rubrique91.html)

Nous souhaitons mutualiser le code SPIP utilisé sur toutes les CCNs en un seul conteneur déployé.
Cela afin de permettre de simplifier la maintenance et les futurs déploiements.

## Pré-requis

### Base de données

Il faut avoir une base de données déjà disponible.

#### SPIP 4
Pour `SPIP 4`, le code suivant a été ajouté au fichier `mes_options.php` :
```php
/*
 * Déclaration de l'encodage utf-8 de la base de données.
 * https://contrib.spip.net/Astuces-longues-pour-SPIP
 */
if (!defined('_ECRIRE_INC_VERSION')) {
    return;
}
// Pour permettre les index de plus de 1000 octets (2 tables du core concernées, dont spip_metas
define('_MYSQL_ENGINE', 'InnoDB');
```

Pour **SPIP 3**, cette base doit *impérativement* être encodée en `isolatin` !
```sql
-- Création d'une base en iso-latin.
CREATE DATABASE ccn CHARACTER SET = 'latin1' COLLATE = 'latin1_general_ci';
```
Ou alors :
```sql
-- Modification d'une base déjà existante :
ALTER DATABASE ccn COLLATE = 'latin1_general_ci';
```

#### Connexion à la BDD

Quelque soit votre version de SPIP et votre encodage de la base de données, vous devez en déclarer les modalités de
connexion à SPIP pour qu'il puisse s'y connecter. Deux choix s'offrent à vous :
- Les déclarer en variables d'environnement (directement via `rancher`/`docker` dans notre cas).
- Les déclarer dans le fichier `mes_options.php`

```php
// Exemple dans le fichier mes_options.php qui récupère les données en variable d'environnement.
define ('_INSTALL_SERVER_DB', getenv('DB_TYPE'));
define ('_INSTALL_HOST_DB', getenv('DB_HOSTNAME'));
define ('_INSTALL_USER_DB', getenv('DB_USERNAME'));
define ('_INSTALL_PASS_DB', getenv('DB_USER_PASSWORD'));
define ('_INSTALL_NAME_DB', getenv('DB_TABLE_NAME'));
```

Notez que SPIP n'accepte que les bases de données de type `sqlite` ou `mysql` (qui inclut `mariadb`). Cela
correspond à la constante `_INSTALL_SERVER_DB`.

## Principe général

Le conteneur récupère une version récente d'*apache* et de *PHP* avec tous les modules nécessaires, y télécharge et
installe SPIP et finalement injecte la configuration générale (le fichier `mes_options.php`).

### Volume

Un bon compromis pour installer un volume serait de le faire pointer vers `/var/www/html/sites/`. Cela a l'avantage de
contenir toutes les instances des CCN mais a comme inconvénient de contenir le cache.


## Exemple de déploiement d'une CCN

Une fois le conteneur lancé, il contient une *ferme à SPIP*. À nous d'ajouter au fur et à mesure les CCN que nous
voulons.

### Préparatifs SPIP

```shell
# Nous prendrons comme exemple, le petitfablab que nous souhaitons faire pointer vers petitfablab.laclasse.com

# Création des dossiers nécessaires à SPIP.
mkdir -p /var/www/html/sites/petitfablab.laclasse.com/IMG && \
    mkdir -p /var/www/html/sites/petitfablab.laclasse.com/tmp/dump && \
    mkdir -p /var/www/html/sites/petitfablab.laclasse.com/local && \
    mkdir -p /var/www/html/sites/petitfablab.laclasse.com/config

# Droits donnés à apache sur ces dossiers.
chown -R www-data:www-data /var/www/html/sites/
```

Une fois ces préliminaires achevés, nous pouvons commencer l'installation proprement dite via l'interface web de SPIP.
Dans notre exemple, cet interface se trouve donc à l'adresse
[petitfablab.laclasse.com/ecrire/](petitfablab.laclasse.com/ecrire/).

Tous les paramètres ont été inscrits par défaut dans `mes_options.php`, à l'exception du premier utilisateur admin.



# Installation CCN

Une fois les paramètres choisis, votre site SPIP devrait être fonctionnel. À présent, il faut installer la CCN
elle-même. Dans le cas qui nous concerne, le `petitfablab` est une CCN de type *air*/*fictions*. Il lui faut donc les
squelettes correspondants :
```shell
# Pour cet exemple (petitfblab), on travaillera sur une branche de dév particulière.
git clone --branch dev-spip4 https://github.com/ccnum/plugin_air_laclasse.git /var/www/html/sites/petitfablab.laclasse.com/squelettes/
```

## Configurations

### Données générales

Dans l'espace admin, modifiez les données générales de votre CCN. Dans notre exemple :
`https://petitfablab.laclasse.com/ecrire/?exec=configurer_identite`

![Configuration identité site SPIP](/img/pfl_identité.avif "Configuration identité site SPIP")


- credentials en docker secrets
- arguments (url du code spip) en variables dans l'interface github
- arguments en variable d'env du déploiement (sur rancher)

# todo

- dockerignore
- optimize size build
- documentation pour création d'une nouvelle ccn
- better readme (tags, presentation, encarts, etc...)