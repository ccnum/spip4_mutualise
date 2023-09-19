#!/bin/sh
for N in ${LISTE_CCN[@]} ; do
  echo "My name is $N"
  mkdir /var/www/html/$N
done