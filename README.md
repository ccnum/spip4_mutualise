# Dockerisation d'une ferme à SPIP (SPIP4)

[comment]: # (TODO Refaire entièrement et pas-à-pas.)

## Base de données

Avant toute chose, il est nécessaire de créer une base de données que pourra utiliser SPIP. Nous avons choisi d'en avoir
une séparée du pod pour des raisons pratiques (accès externe et réutilisation(s) possible(s)...)

Les choix possibles sont uniquement ***mySQL*** (ou son fork ***mariaDB***) et ***SQLite***.

Quel que sera votre choix, assurez-vous que le hostname de la bdd soit accessible. Dans le cas d'un déploiement docker,
pensez à joindre un volume pour la persistence des données.

-> Côté *Erasme*, se référer à la configuration dans notre système.

## Interface de base de données (optionnel)

Pour des raisons pratiques exceptionnelles, il peut être judicieux d'ajouter une interface de gestion à la base de
données comme `phpmyadmin` ou `adminer`.

Aucun volume n'est nécessaire pour ce déploiement.

-> Côté *Erasme*, se référer à la configuration de notre système.

## SPIP mutualisé

Dans le `Dockerfile`, il vous sera sans doute nécessaire d'ajouter ou compléter la liste des CCN dans le paramètre
d'entrée ou encore de changer la version de SPIP.
```Dockerfile
ENV SPIP_URL="https://files.spip.net/spip/archives/spip-v4.1.5.zip"
ENV SPIP_ZIPFILENAME="spip-v4.1.5.zip"
ENV LISTE_CCN="bd.laclasse.com petitfablab.laclasse.com"
```

L'image docker à lancer est `erasme/spip_mutualisation`. Il sera nécessaire d'ajouter en variables d'environnement les
paramètres suivants :
- `DB_TYPE` (mettez sa valeur à `mysql` même si vous utilisez mariadb, pour les autres cas, voyez la documentation de SPIP)
- `DB_HOSTNAME` (cela peut être l'url d'accès ou le hostname de la bdd comme namespace-nom_du_service_bdd)
- `DB_TABLE_NAME` (la table dans la base de données que vous dédierez à la ferma à SPIP)
- `DB_USERNAME` (le nom d'utilisateur de la bdd)
- `DB_TABLE_NAME` (le mot de passe de l'utilisateur de la base de données)

Une fois le conteneur lancé (n'oubliez pas les certificats, ingresses et services), il suffit d'aller sur l'url d'une
des CCN pour lancer la primo-installation. Tous les paramètres devraient déjà être pré-remplis.

## Post-installation

Une fois votre ferme à SPIP déployée, il sera tout de même nécessaire de faire certaines actions manuellement.

##### Ajouter un dépôt de modules

[Assurez-vous qu'au moins un dépôt soit activé](https://bd.laclasse.com/ecrire/?exec=depots) pour permettre
l'installation des dépendances. Vous pouvez vous contenter  

https://plugins.spip.net/spip.php?page=depots

Activer le dépôt de modules https://nom_ccn.laclasse.com/ecrire/?exec=depots
Activer le module thématique https://nom_ccn.laclasse.com/ecrire/?exec=admin_plugin&voir=tous
Autoriser le post-datage ecrire/?exec=configurer_contenu


### Ajouter une ccn

ajouter son nom dans dockerfile puis redéployer







































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

Pour une installation de plugin commun à toutes les instances, faites ainsi :
```shell
# Nous allons installer le module « thematiques » dans l'espace mutualisé.
cd /var/www/html/plugins
git clone https://github.com/ccnum/plugin_thematique_laclasse.git
# Cet exemple n'est pas encore fonctionnel car ce module a deux dépendances qui ne sont pas encore disponibles. 
```

## Configurations

### Données générales

Dans l'espace admin, modifiez les données générales de votre CCN. Dans notre exemple :
`https://petitfablab.laclasse.com/ecrire/?exec=configurer_identite`

![Configuration identité site SPIP](/img/pfl_identité.avif "Configuration identité site SPIP")


- credentials en docker secrets
- arguments (url du code spip) en variables dans l'interface github
- arguments en variable d'env du déploiement (sur rancher)

## Migration

### Récupération de la base de données.

```shell
# Envoyer le dump de la bdd dans le bon sous-dossier
kubectl -n ccn cp ./bdd.sqlite  id_du_pod_ferme_spip:/var/www/html/sites/nom_ccn.laclasse.com/tmp/dump/bdd.sqlite
```

Restaurez la base via l'interface admin (url de type `https://nom_ccn.laclasse.com/ecrire/?exec=restaurer`). Écrasez
votre ancienne bdd, faites les migrations/conversions que vous pourrait vous demander SPIP et SURTOUT **pensez à vous
créer un utilisateur admin temporaire**. En effet, la restauration de la base de données aura pour effet de vous
attribuer l'identité de l'utilisateur ayant le même id que vous dans la nouvelle base, un nouvel utilisateur admin vous
permettra de vous reconnecter et/ou faire d'autres manipulations.

# todo

- dockerignore
- optimize size build
- documentation pour création d'une nouvelle ccn
- better readme (tags, presentation, encarts, etc...)