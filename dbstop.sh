#!/bin/sh

. ./envsubsonic.sh 

export DB_HOME=${SUBSONIC_HOME}/db
export DB_DATA_FILE=${DB_HOME}/subsonic.data
export SUBSONIC_JARS_DIR=${SUBSONIC_HOME}/jetty/1/webapp/WEB-INF/lib
export DB_CLASS_PATH=${SUBSONIC_JARS_DIR}/sqltool-2.3.2.jar:${SUBSONIC_JARS_DIR}/hsqldb-1.8.0.7.jar

java -cp ${DB_CLASS_PATH} \
	org.hsqldb.util.SqlTool \
	--driver org.hsqldb.jdbcDriver \
	--sql 'SHUTDOWN COMPACT' \
	--inlineRc URL=jdbc:hsqldb:hsql://localhost/subsonic,USER=sa <<EOF

EOF



