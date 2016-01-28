#!/bin/sh

rm -rf /DATA/biconou/subsonic_home/db/*

cd /

FILE=db-2016-01-13.tgz

echo restauration de ${FILE}
tar xvfz /mnt/NAS/REMI/SAUVEGARDE/biconouBase/${FILE}

