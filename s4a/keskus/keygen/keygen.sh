#!/bin/sh

# Copyright (C) 2010, Cybernetica AS, http://www.cybernetica.eu/

KEYGENDIR="/usr/local/s4a-centre/keygen"
CERTDIR="/etc/ssl"
PRIVDIR="$CERTDIR/private"

set -e

if [ "$1" = "" ]
then
	echo "First argument should be site name!"
	exit 1
fi

# genereerin paringu
openssl req -sha1  -new -keyout server.key -config webconf.cnf -subj "/C=ee/CN=$1" -out server.csr -nodes

# ja sertifitseerin selle
openssl x509 -req -days 3600 -in server.csr -signkey server.key -out server.crt

# Panen failid kuhu vaja
if [ -s $CERTDIR/server.crt ]
then
	mv $CERTDIR/server.crt $CERTDIR/server.crt.`date '+%s'`
fi
mv $KEYGENDIR/server.crt $CERTDIR/server.crt
if [ -s $PRIVDIR/server.key ]
then
	mv $PRIVDIR/server.key $PRIVDIR/server.key.`date '+%s'`
fi
mv $KEYGENDIR/server.key $PRIVDIR/server.key

apachectl configtest
echo "Please restart apache when setup finished!"
