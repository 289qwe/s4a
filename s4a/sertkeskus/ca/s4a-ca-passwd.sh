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
trap clear_capassword EXIT
ask_capassword
ask_new_capassword

$S4A_CA_OPENSSL rsa -aes256 -in $PRIV_KEY -out $PRIV_KEY  -passin file:$S4A_CURRENT_PASS  -passout file:$S4A_NEW_PASS 

exit 0
