<?php
/***********************************************************************************************************************
 *                                                  DOCUMENTATIONS
 **********************************************************************************************************************/
/*
 * Pour comprendre le fonctionnement de ce fichier, voyez les pages suivantes :
 * https://framagit.org/-/snippets/2674
 * https://www.spip.net/fr_article4654.html
 * https://contrib.spip.net/Et-si-spip-est-dans-un-sous-repertoire
 * https://doc.cliss21.com/wiki/Plugin_SPIP
 */

/***********************************************************************************************************************
 *                                                  BDD
 **********************************************************************************************************************/
/*
 * Déclaration de l'encodage utf-8 de la base de données.
 * https://contrib.spip.net/Astuces-longues-pour-SPIP
 */
if (!defined('_ECRIRE_INC_VERSION')) {
    return;
}
// Pour permettre les index de plus de 1000 octets (2 tables du core concernées, dont spip_metas
define('_MYSQL_ENGINE', 'InnoDB');

// Facultatif : pour garder la compat des plugins avec SPIP 4.0 ; supprimer le dépôt et le remettre pour tenir compte de cette modification
//define('_DEV_VERSION_SPIP_COMPAT',"4.0.0");

/*
 * Les 5 variables suivantes doivent être déclarées en variables d'environnement (idéalement au lancement du conteneur)
 * Soit on déclare ces variables dans la commande docker run.....
 * Soit on les déclare dans rancher.
 *
 * On a choisi de les passer dans rancher : plus besoin de les déclarer en dur ici.
 */
define ('_INSTALL_SERVER_DB', getenv('DB_TYPE'));
define ('_INSTALL_HOST_DB', getenv('DB_HOSTNAME'));
define ('_INSTALL_USER_DB', getenv('DB_USERNAME'));
define ('_INSTALL_PASS_DB', getenv('DB_USER_PASSWORD'));
define ('_INSTALL_NAME_DB', getenv('DB_TABLE_NAME'));


/***********************************************************************************************************************
 *                                                  CONFIGURATIONS
 **********************************************************************************************************************/
/*
 * Déclaration des emplacements des fichiers squelettes. -> Ne marche pas pour le BO (côté /ecrire/ )
 * Ceux-cis sont de type /var/www/html/sites/NOM_DE_LA_CCN/squelettes/
 * Ex :
 * - /var/www/html/sites/petitfablab.laclasse.com/squelettes/
 * - ... <-- penser à tester/vérifier pour les autres futures CCN
 */
if ( is_dir('sites/' . $_SERVER['HTTP_HOST'] . '/squelettes') ) {
    $GLOBALS['dossier_squelettes'] = 'sites/' . $_SERVER['HTTP_HOST'] . '/squelettes';
}

/**
 * Configuration du préfixe des tables.
 * Avons-nous bien une url de type NOM_CCN.laclasse.com ?
 * - oui → on renvoie NOM_CCN
 * - non → on renvoie NOM_CCN.laclasse.com
 * @return string
 */
function getPrefixeTableSpip(): string
{
    $frags = explode('.', $_SERVER['HTTP_HOST']);
    if ( count($frags)===3 && $frags[1]==='laclasse' && $frags[2]==='com'){
        return $frags[0];
    }
    return $_SERVER['HTTP_HOST'];
}

/**
 * Configuration spécifique à la mutualisation (ferme à SPIP)
 * Voir la documentation ici : https://www.spip.net/fr_article3811.html
 */
$rep = 'sites/'; // Dans quel sous-repertoire du serveur sont stockés les différentes ccn
$site = $_SERVER['HTTP_HOST'];
$path = _DIR_RACINE . $rep . $site . '/'; // Chemin d'accès aux fichiers.
define('_SPIP_PATH', // Ordre de recherche des chemins (les squelettes seront chargés successivement depuis ces répertoires).
    $path . ':' .
    _DIR_RACINE .':' .
    _DIR_RACINE .'squelettes-dist/:' .
    _DIR_RACINE .'prive/:' .
    _DIR_RESTREINT);
// Nom et emplacement des fichiers de log.
define('_FILE_LOG_SUFFIX', '_' . $site . '.log');
define('_DIR_LOG',  _DIR_RACINE . 'log/');
// Préfixes des cookies.
$cookie_prefix = str_replace('.', '_', $site);
$table_prefix = getPrefixeTableSpip(); // Fonction créée plus haut dans ce fichier.
if (is_readable($f = $path . _NOM_PERMANENTS_INACCESSIBLES . _NOM_CONFIG . '.php')) {// Exécution du fichier config/mes_option.php du site mutualisé.
    include($f);
}

/***********************************************************************************************************************
 *                                                  DÉMARRAGE DU SITE
 **********************************************************************************************************************/
spip_initialisation(
    ($path . _NOM_PERMANENTS_INACCESSIBLES),
    ($path . _NOM_PERMANENTS_ACCESSIBLES),
    ($path . _NOM_TEMPORAIRES_INACCESSIBLES),
    ($path . _NOM_TEMPORAIRES_ACCESSIBLES)
);