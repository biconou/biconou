#!/bin/sh

. ./envsubsonic.sh 

export DB_HOME=${SUBSONIC_HOME}/db
export DB_DATA_FILE=${DB_HOME}/subsonic
export SUBSONIC_JARS_DIR=${SUBSONIC_HOME}/jetty/1/webapp/WEB-INF/lib
export DB_CLASS_PATH=${SUBSONIC_JARS_DIR}/hsqldb-1.8.0.7.jar:${SUBSONIC_JARS_DIR}/sqltool-2.3.2.jar

nohup java -cp ${DB_CLASS_PATH} \
	org.hsqldb.Server -database.0 file:${DB_DATA_FILE} -dbname.0 subsonic \
	> nohup.dbstart.out 2>&1&
