# Dockerisation d'une ferme à SPIP (SPIP4)

[Qu'est-ce que SPIP ?](https://www.spip.net/fr_rubrique91.html)

Nous souhaitons mutualiser le code SPIP utilisé sur toutes les CCNs en un seul conteneur déployé.
Cela afin de permettre de simplifier la maintenance et les futurs déploiements.

## Pré-requis

### Base de données

Il faut avoir une base de données déjà disponible. Cette base doit *impérativement* être encodée en `isolatin` !
```sql
-- Création d'une base en iso-latin.
CREATE DATABASE ccn CHARACTER SET = 'latin1' COLLATE = 'latin1_general_ci';
```
Ou alors :
```sql
-- Modification d'une base déjà existante :
ALTER DATABASE ccn COLLATE = 'latin1_general_ci';
```


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
    mkdir -p /var/www/html/sites/petitfablab.laclasse.com/tmp && \
    mkdir -p /var/www/html/sites/petitfablab.laclasse.com/local && \
    mkdir -p /var/www/html/sites/petitfablab.laclasse.com/config

# Droits donnés à apache sur ces dossiers.
chown -R www-data:www-data /var/www/html/sites/
```

Une fois ces préliminaires achevés, nous pouvons commencer l'installation proprement dite via l'interface web de SPIP.
Dans notre exemple, cet interface se trouve donc à l'adresse
[petitfablab.laclasse.com/ecrire/](petitfablab.laclasse.com/ecrire/).

# Installation CCN

Une fois les paramètres choisis, votre site SPIP devrait être fonctionnel. À présent, il faut installer la CCN
elle-même. Dans le cas qui nous concerne, le `petitfablab` est une CCN de type *air*/*fictions*. Il lui faut donc les
squelettes correspondants :
```shell
# Pour cet exemple (petitfblab), on travaillera sur une branche de dév particulière.
git clone --branch dev-pa https://github.com/ccnum/plugin_air_laclasse.git /var/www/html/sites/petitfablab.laclasse.com/squelettes/
```





- credentials en docker secrets
- arguments (url du code spip) en variables dans l'interface github
- arguments en variable d'env du déploiement (sur rancher)

# todo

- dockerignore
- optimize size build
- lighter base image
- documentation pour création d'une nouvelle ccn
- better readme (tags, presentation, encarts, etc...)