#! /bin/sh

# Copyright (C) 2010, Cybernetica AS, http://www.cybernetica.eu/

CERTDIR="/etc/ssl"
PRIVDIR="$CERTDIR/private"
set -e

if [ "$1" = "" ]
then
	echo "First argument should be subject name!"
	exit 1
fi

SUBJEKT="$1"

# eraldusnimi veebiserveri cerdile
# NB: CN peab olema lõpus!
DISNAME="/C=EE/CN=$SUBJEKT"

NEWKEY="confservkey.key"
NEWREQ="confservkey.req"

if [ -s $NEWREQ ]
then
	mv $NEWREQ $NEWREQ.`date '+%s'`
fi

openssl req -sha512 -new -keyout $NEWKEY -out $NEWREQ -nodes -subj "$DISNAME" -newkey rsa:2048

# panen failid kuhu vaja
if [ -s $PRIVDIR/$NEWKEY ]
then
	mv $PRIVDIR/$NEWKEY $PRIVDIR/$NEWKEY.`date '+%s'`
fi
mv $NEWKEY $PRIVDIR/$NEWKEY

echo "\nPlease transmit the file \"$NEWREQ\" to the CA administrator for certify"
