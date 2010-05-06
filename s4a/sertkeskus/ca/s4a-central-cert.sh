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
	echo "First argument should be request file name!"
	exit 1
fi

if [ ! -f "$1" ]
then
	echo "Request file $1 does not exist!"
	exit 1
fi

ask_capassword

CACERTFILE="cacert.pem"
NEWCACERT="$TEMP_DIR/$CACERTFILE"
cp "$CA_CERT" "$NEWCACERT"

NEWREQ="$1"
CONFSERVNAME=`$S4A_CA_BIN/s4a-request-show.sh $NEWREQ | grep "Subject:.*C=.*, CN=" | sed -n 's/.*Subject:.*CN=*// p'`
NEWCERTFILE="confservkey.crt"

NEWCERT="$TEMP_DIR/$NEWCERTFILE"
NEWTAR="$TEMP_DIR/$CONFSERVNAME.tgz"

rm -f "$NEWCERT"

$S4A_CA_OPENSSL ca -config $CONFIG -in $NEWREQ -out $NEWCERT -extensions web_cert -passin file:"$S4A_CURRENT_PASS"

if [ -d "$BUNDLE_DIR" ]
then
	LIST=`ls "$BUNDLE_DIR"`
	for each in $LIST
	do
		cat "$BUNDLE_DIR"/$each >> $NEWCACERT
	done
fi

tar -C $TEMP_DIR -czf $NEWTAR "$NEWCERTFILE" "$CACERTFILE"

WEBSERVDIR="$CA_DIR/localcert"
WEBSERVCERT="$CONFSERVNAME.crt"

if [ ! -d "$WEBSERVDIR" ];
then
	mkdir "$WEBSERVDIR"
fi

rm "$NEWCACERT"
mv "$NEWCERT" "$WEBSERVDIR/$WEBSERVCERT"
mv "$NEWTAR" "$OUTPUT_DIR"

echo ""
echo "created successfully $CONFSERVNAME certificate to $OUTPUT_DIR"
echo ""

exit 0
