#! /bin/sh

# /* Copyright (C) 2010, Cybernetica AS, http://www.cybernetica.eu/ */


set -e

if [ "$S4A_CA_BIN" = "" ]
then
	echo "S4A_CA_BIN environment variable must be set!"
	exit 1
fi

. $S4A_CA_BIN/util.sh

trap clear_capassword EXIT

init_binaries
init_ca
ask_capassword

$S4A_CA_OPENSSL rsa -in $PRIV_KEY -passin file:"$S4A_CURRENT_PASS" -check 
