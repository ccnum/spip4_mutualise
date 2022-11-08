<?php
$rep = 'sites/';
$site = $_SERVER['HTTP_HOST'];
$path = _DIR_RACINE . $rep . $site . '/';

/*
 * Les 5 variables suivantes doivent être déclarées en variables d'environnement (idéalement au lancement du conteneur)
 * Soit on déclare ces variables dans la commande docker run.....
 * Soit on les déclare dans rancher.
 */

/*
define ('_INSTALL_SERVER_DB', getenv('DB_TYPE'));
define ('_INSTALL_HOST_DB', getenv('DB_HOSTNAME'));
define ('_INSTALL_USER_DB', getenv('DB_USERNAME'));
define ('_INSTALL_PASS_DB', getenv('DB_USER_PASSWORD'));
define ('_INSTALL_NAME_DB', getenv('DB_TABLE_NAME'));
*/

// ordre de recherche des chemins
define('_SPIP_PATH',
    $path . ':' .
    _DIR_RACINE .':' .
    _DIR_RACINE .'squelettes-dist/:' .
    _DIR_RACINE .'prive/:' .
    _DIR_RESTREINT);

// ajout du dossier squelette
if (is_dir($path . 'squelettes'))
    $GLOBALS['dossier_squelettes'] = $rep . $site . '/squelettes';

// exemple de logs a la racine pour tous les sites
define('_FILE_LOG_SUFFIX', '_' . $site . '.log');
define('_DIR_LOG',  _DIR_RACINE . 'log/');

// prefixes des cookie et des tables :
$cookie_prefix = str_replace('.', '_', $site);
$table_prefix = 'spip';

// exectution du fichier config/mes_option.php du site mutualise
if (is_readable($f = $path . _NOM_PERMANENTS_INACCESSIBLES . _NOM_CONFIG . '.php'))
    include($f);

// demarrage du site
spip_initialisation(
    ($path . _NOM_PERMANENTS_INACCESSIBLES),
    ($path . _NOM_PERMANENTS_ACCESSIBLES),
    ($path . _NOM_TEMPORAIRES_INACCESSIBLES),
    ($path . _NOM_TEMPORAIRES_ACCESSIBLES)
);
?>