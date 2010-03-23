#!/bin/sh

# /* Copyright (C) 2010, Cybernetica AS, http://www.cybernetica.eu/ */


SSLCONF="ssl.conf"

KEYFILE="s4apatch.key"
REQFILE="s4apatch.req"

OPENSSL="openssl"

if [ -f "$KEYFILE" ]; then
	echo "Keyfile already exist, refusing to overwrite!"
	exit 1
fi

if [ ! -f $SSLCONF ]; then
	echo "# Automatically generated file" >  $SSLCONF
	echo "[ req ]" >> $SSLCONF
	echo "default_bits = 4096" >> $SSLCONF
	echo "distinguished_name = req_distinguished_name" >> $SSLCONF
	echo "prompt = no" >> $SSLCONF
	echo "[ req_distinguished_name ]" >> $SSLCONF
	echo "C = EE" >> $SSLCONF
	echo "O = S4A" >> $SSLCONF
	echo "CN =  S4A patching system" >> $SSLCONF
	echo "# eof" >> $SSLCONF
fi

$OPENSSL req -config $SSLCONF -new -sha512 -out $REQFILE -keyout $KEYFILE -newkey rsa:4096

ret=$?
if [ $ret -ne 0 ]; then
	echo "ERROR: key generation failed!"
	exit $ret
fi

echo "\nPlease transmit the $REQFILE to the CA administrator for certify"
