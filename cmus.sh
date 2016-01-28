#!/bin/sh

###################################################################################
# Shell script for starting cmus.
#
# Author: Rémi Cocula
###################################################################################

if [ -z "${SUBSONIC_HOME}" ]
then
  SUBSONIC_HOME=/biconou/subsonic_home
fi

export WRK_DIR=/biconou

#Test is a cmus process is already running

wrkStatus=`cmus-remote -C status | head -1 | cut -d ' ' -f 2`
echo "cmus status is : ${wrkStatus}"

if [ -z "${wrkStatus}" ] 
then
  echo "Start cmus in background" 
  nohup cmus --listen 0.0.0.0:4041 > /dev/null &
  echo $! > ${WRK_DIR}/cmus.pid
  wrkCmusPid=`cat ${WRK_DIR}/cmus.pid`
#  sudo renice -10 ${wrkCmusPid}
fi

ps -ef | grep cmus







