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

VOLUME

- credentials en docker secrets
- arguments (url du code spip) en variables dans l'interface github
- arguments en variable d'env du déploiement (sur rancher)

# todo

- dockerignore
- optimize size build
- lighter base image
- documentation pour création d'une nouvelle ccn
- better readme (tags, presentation, encarts, etc...)