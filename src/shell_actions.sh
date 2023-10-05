#!/bin/sh
for CCN in $LISTE_CCN ; do
  mkdir -p /var/www/html/sites/$CCN/IMG
  mkdir /var/www/html/sites/$CCN/tmp
  mkdir /var/www/html/sites/$CCN/local
  mkdir /var/www/html/sites/$CCN/config
done