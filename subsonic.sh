#!/bin/sh

###################################################################################
# Shell script for starting Subsonic.  See http://subsonic.org.
#
# Author: Sindre Mehus
###################################################################################


. ./envsubsonic.sh

echo "SUBSONIC_HOME = ${SUBSONIC_HOME}"

cd ./subsonic

SUBSONIC_HOST=0.0.0.0
SUBSONIC_PORT=4040
SUBSONIC_HTTPS_PORT=0
SUBSONIC_CONTEXT_PATH=/
SUBSONIC_MAX_MEMORY=256
SUBSONIC_PIDFILE=${SUBSONIC_PID}
SUBSONIC_DEFAULT_MUSIC_FOLDER=/var/music
SUBSONIC_DEFAULT_PODCAST_FOLDER=/var/music/Podcast
SUBSONIC_DEFAULT_PLAYLIST_FOLDER=/var/playlists

quiet=0

usage() {
    echo "Usage: subsonic.sh [options]"
    echo "  --help               This small usage guide."
    echo "  --home=DIR           The directory where Subsonic will create files."
    echo "                       Make sure it is writable. Default: /var/subsonic"
    echo "  --host=HOST          The host name or IP address on which to bind Subsonic."
    echo "                       Only relevant if you have multiple network interfaces and want"
    echo "                       to make Subsonic available on only one of them. The default value"
    echo "                       will bind Subsonic to all available network interfaces. Default: 0.0.0.0"
    echo "  --port=PORT          The port on which Subsonic will listen for"
    echo "                       incoming HTTP traffic. Default: 4040"
    echo "  --https-port=PORT    The port on which Subsonic will listen for"
    echo "                       incoming HTTPS traffic. Default: 0 (disabled)"
    echo "  --context-path=PATH  The context path, i.e., the last part of the Subsonic"
    echo "                       URL. Typically '/' or '/subsonic'. Default '/'"
    echo "  --max-memory=MB      The memory limit (max Java heap size) in megabytes."
    echo "                       Default: 100"
    echo "  --pidfile=PIDFILE    Write PID to this file. Default not created."
    echo "  --quiet              Don't print anything to standard out. Default false."
    echo "  --default-music-folder=DIR    Configure Subsonic to use this folder for music.  This option "
    echo "                                only has effect the first time Subsonic is started. Default '/var/music'"
    echo "  --default-podcast-folder=DIR  Configure Subsonic to use this folder for Podcasts.  This option "
    echo "                                only has effect the first time Subsonic is started. Default '/var/music/Podcast'"
    echo "  --default-playlist-folder=DIR Configure Subsonic to use this folder for playlists.  This option "
    echo "                                only has effect the first time Subsonic is started. Default '/var/playlists'"
    echo "  --jmx                Activate JMX."
    echo "  --externaldb         Run external data base."
    exit 1
}

# Parse arguments.
while [ $# -ge 1 ]; do
    case $1 in
        --help)
            usage
            ;;
        --home=?*)
            SUBSONIC_HOME=${1#--home=}
            ;;
        --host=?*)
            SUBSONIC_HOST=${1#--host=}
            ;;
        --port=?*)
            SUBSONIC_PORT=${1#--port=}
            ;;
        --https-port=?*)
            SUBSONIC_HTTPS_PORT=${1#--https-port=}
            ;;
        --context-path=?*)
            SUBSONIC_CONTEXT_PATH=${1#--context-path=}
            ;;
        --max-memory=?*)
            SUBSONIC_MAX_MEMORY=${1#--max-memory=}
            ;;
        --pidfile=?*)
            SUBSONIC_PIDFILE=${1#--pidfile=}
            ;;
        --quiet)
            quiet=1
            ;;
        --default-music-folder=?*)
            SUBSONIC_DEFAULT_MUSIC_FOLDER=${1#--default-music-folder=}
            ;;
        --default-podcast-folder=?*)
            SUBSONIC_DEFAULT_PODCAST_FOLDER=${1#--default-podcast-folder=}
            ;;
        --default-playlist-folder=?*)
            SUBSONIC_DEFAULT_PLAYLIST_FOLDER=${1#--default-playlist-folder=}
            ;;
        --jmx)
            JMX_OPTIONS="-Dcom.sun.management.jmxremote"
            JMX_OPTIONS="${JMX_OPTIONS} -Dcom.sun.management.jmxremote.port=9010"
            JMX_OPTIONS="${JMX_OPTIONS} -Dcom.sun.management.jmxremote.local.only=false"
            JMX_OPTIONS="${JMX_OPTIONS} -Dcom.sun.management.jmxremote.authenticate=false"
            JMX_OPTIONS="${JMX_OPTIONS} -Dcom.sun.management.jmxremote.ssl=false"
            JMX_OPTIONS="${JMX_OPTIONS} -Djava.rmi.server.hostname=192.168.0.11"
            ;;
        --externaldb)
			EXTERNAL_DB="-Dcom.github.biconou.serverDB.url=jdbc:hsqldb:hsql://localhost/subsonic"
			EXTERNAL_DB="${EXTERNAL_DB} -Dcom.github.biconou.serverDB.username=sa"
			EXTERNAL_DB="${EXTERNAL_DB} -Dcom.github.biconou.serverDB.password="""
            ;;
        *)
            usage
            ;;
    esac
    shift
done

# Use JAVA_HOME if set, otherwise assume java is in the path.
JAVA=java
if [ -e "${JAVA_HOME}" ]
    then
    JAVA=${JAVA_HOME}/bin/java
fi
echo "Java command is ${JAVA}"

# Create Subsonic home directory.
echo "Create SUBSONIC_HOME if does not exists"
mkdir -p ${SUBSONIC_HOME}
LOG=${SUBSONIC_HOME}/subsonic_sh.log
rm -f ${LOG}

if [ -n "${EXTERNAL_DB}" ]
	then
	echo "Start external data base"
	cd ..
	. ./dbstart.sh
	cd ./subsonic
	sleep 20
fi

cd $(dirname $0)
if [ -L $0 ] && ([ -e /bin/readlink ] || [ -e /usr/bin/readlink ]); then
    cd $(dirname $(readlink $0))
fi


echo "Launch subsonic"
${JAVA} -Xmx${SUBSONIC_MAX_MEMORY}m \
  ${JMX_OPTIONS} \
  ${EXTERNAL_DB} \
  -Dsubsonic.home=${SUBSONIC_HOME} \
  -Dsubsonic.host=${SUBSONIC_HOST} \
  -Dsubsonic.port=${SUBSONIC_PORT} \
  -Dsubsonic.httpsPort=${SUBSONIC_HTTPS_PORT} \
  -Dsubsonic.contextPath=${SUBSONIC_CONTEXT_PATH} \
  -Dsubsonic.defaultMusicFolder=${SUBSONIC_DEFAULT_MUSIC_FOLDER} \
  -Dsubsonic.defaultPodcastFolder=${SUBSONIC_DEFAULT_PODCAST_FOLDER} \
  -Dsubsonic.defaultPlaylistFolder=${SUBSONIC_DEFAULT_PLAYLIST_FOLDER} \
  -Djava.awt.headless=true \
  -verbose:gc \
  -jar subsonic-booter-jar-with-dependencies.jar > ${LOG} 2>&1 &


# Write pid to pidfile if it is defined.
echo "Write pid in ${SUBSONIC_PIDFILE}"
if [ $SUBSONIC_PIDFILE ]; then
    echo $! > ${SUBSONIC_PIDFILE}
fi

if [ $quiet = 0 ]; then
    echo Started Subsonic [PID $!, ${LOG}]
fi

