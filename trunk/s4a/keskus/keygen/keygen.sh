#!/bin/sh

# Copyright (C) 2010, Cybernetica AS, http://www.cybernetica.eu/


set -e

if [ "$1" = "" ]
then
	echo "First argument should be site name!"
	exit 1
fi

# genereerin paringu
openssl req -sha1  -new -keyout server.key -config /var/www/keygen/webconf.cnf -subj "/C=ee/CN=$1" -out server.csr -nodes

# ja sertifitseerin selle
openssl x509 -req -days 3600 -in server.csr -signkey server.key -out server.crt

# Panen failid kuhu vaja

cp /var/www/keygen/server.crt /etc/ssl/server.crt
cp /var/www/keygen/server.key /etc/ssl/private/server.key

apachectl configtest

apachectl stop
sleep 3
apachectl start
