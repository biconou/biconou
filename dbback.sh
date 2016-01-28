#!/bin/sh


. ./envsubsonic.sh

echo "Arret de subsonic ..."
. ./subsonic_stop.sh

echo "Suppression des fichiers de log ..."
rm ${SUBSONIC_HOME}/*.log

sleep 20

echo "Demarrage de la base ..."
. ./dbstart.sh
sleep 20
echo "Arret de la base ..."
. ./dbstop.sh

echo "Archivage ..."
DATE=`date +%Y-%m-%d`
tar -zcvf /mnt/NAS/REMI/SAUVEGARDE/biconouBase/db-${DATE}.tgz  ${SUBSONIC_HOME}/db  2>&1  

echo "Demarrage de subsonic"
. ./subsonic.sh
