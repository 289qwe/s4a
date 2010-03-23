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

init_s4a_ca

if [ "$1" = "" ]
then
	echo "First argument must be subject name!"
	exit 1
fi

if [ "$2" = "" ]
then
	echo "Second argument must be Organisation name!"
	exit 1
fi

if [ "$3" = "" ]
then
	echo "Third argument must be Full name!"
	exit 1
fi

if [ "$4" = "" ]
then
	echo "Fourth argument must be request file name!"
	exit 1
fi

if [ "$5" = "" ]
then
	echo "Fifth argument must be s4a central server certificate file name!"
	exit 1
fi

SUBJEKT="$1"
ORG="$2"
OU="$3"
NEWREQ="$4"
WEBSERVCERT="$5"
WEBSERVDIR="$CA_DIR/localcert"

if [ ! -f "$NEWREQ" ]
then
	echo "File $NEWREQ does not exist!"
	exit 1
fi

if [ ! -f "$WEBSERVCERT" ]
then
	echo "s4a central server certificatefile $WEBSERVCERT does not exists!" 
	exit 1
fi

SERVNAME=`sed -n 's/.*Subject:.*CN *= *// p'  "$WEBSERVCERT"`
DISNAME="/C=EE/CN=$SUBJEKT/O=$ORG/OU=$OU/L=$SERVNAME"

ask_capassword

NEWCACERT="$TEMP_DIR/cacert.crt"
NEWPATCHCERT="$TEMP_DIR/s4apatch.pem"

cp "$CA_CERT" "$NEWCACERT"
if [ -f "$WEBSERVDIR/s4apatch.pem" ]
then
	cp "$WEBSERVDIR/s4apatch.pem" "$NEWPATCHCERT"
fi

NEWCERT="$TEMP_DIR/tuvastaja.crt"
NEWTAR="$TEMP_DIR/$SUBJEKT.tgz"

rm -f "$NEWCERT" "$NEWTAR" 
$S4A_CA_OPENSSL ca -config $CONFIG -in $NEWREQ -out $NEWCERT  -extensions usr_cert -subj "$DISNAME" -passin file:"$S4A_CURRENT_PASS"

if [ -f "$BUNDLE_FILE" ]
then
	cat $BUNDLE_FILE >> $NEWCACERT
fi

if [ -f "$NEWPATCHCERT" ]
then
	tar -C $TEMP_DIR -czf  $NEWTAR tuvastaja.crt cacert.crt s4apatch.pem
else 
	tar -C $TEMP_DIR -czf  $NEWTAR tuvastaja.crt cacert.crt
fi

rm -f "$NEWCERT" "$NEWCACERT" "$NEWPATCHCERT"
mv "$NEWTAR" "$OUTPUT_DIR"

echo ""
echo "created successfully $SUBJEKT to $OUTPUT_DIR"
echo ""

exit 0
