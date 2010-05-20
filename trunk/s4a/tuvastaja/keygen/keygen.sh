#!/bin/sh

# /* Copyright (C) 2010, Cybernetica AS, http://www.cybernetica.eu/ */


set -e

if [ "$1" = "" ]
then
	echo "First argument should be site name!"
	exit 1
fi

GENDIR=`dirname $0`

CONFFILE="$GENDIR/haldusveeb.cnf"
KEYFILE="$GENDIR/server.key"
REQFILE="$GENDIR/server.csr"
CERTFILE="$GENDIR/server.crt"

# genereerin paringu
openssl req -sha1  -new -keyout "$KEYFILE" -config "$CONFFILE"  -subj "/C=ee/CN=$1" -out "$REQFILE" -nodes

# ja sertifitseerin selle
openssl x509 -req -days 3600 -in "$REQFILE" -signkey "$KEYFILE" -out "$CERTFILE"

# Panen failid kuhu vaja

mv "$CERTFILE" /var/www/tuvastaja/data/apache/ssl/server.crt
mv "$KEYFILE"  /var/www/tuvastaja/data/apache/ssl/private/server.key
rm "$REQFILE"

