#!/bin/sh

. ./envsubsonic.sh 


PID=`cat ${SUBSONIC_PID}`

kill -9 ${PID}


