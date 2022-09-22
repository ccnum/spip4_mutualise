# Dockerisation d'une ferme à SPIP (SPIP4)

[Qu'est-ce que SPIP ?](https://www.spip.net/fr_rubrique91.html)

Nous souhaitons mutualiser le code SPIP utilisé sur toutes les CCNs en un seul conteneur déployé.
Cela afin de permettre de simplifier la maintenance et les futurs déploiements.

## Pré-requis

Nous avons déjà un conteneur `mariadb` déployé dans un namespace `ccn`, cette ferme à SPIP devra
être déployé dans le même namespace.

## Principe général

- credentials en docker secrets
- arguments (url du code spip) en variables dans l'interface github
- arguments en variable d'env du déploiement (sur rancher)