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
	echo "First argument should be request file name!"
	exit 1
fi

REQUEST="$1"

if [ ! -e "$REQUEST" ];
then
	echo "File $REQUEST does not exist!"
	exit 1
fi

$S4A_CA_OPENSSL  req -in $REQUEST -text -noout 

exit 0
