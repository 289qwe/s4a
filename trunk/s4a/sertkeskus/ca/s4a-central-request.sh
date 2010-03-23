#! /bin/sh

# /* Copyright (C) 2010, Cybernetica AS, http://www.cybernetica.eu/ */


set -e

if [ "$S4A_CA_BIN" = "" ]
then
	echo "S4A_CA_BIN environment variable must be set!"
	exit 1 
fi

. $S4A_CA_BIN/util.sh

init_s4a_ca

if [ "$1" = "" ]
then
	echo "First argument should be subject name!"
	exit 1
fi

SUBJEKT="$1"

# erladusnimi veebiserveri cerdile
# NB: CN peab olema lõpus!
DISNAME="/C=EE/CN=$SUBJEKT"

NEWKEY="confservkey.key"
NEWREQ="confservkey.req"

$S4A_CA_OPENSSL req -sha512 -new -keyout $NEWKEY -config $CONFIG -out $NEWREQ -nodes -subj "$DISNAME"

exit 0
