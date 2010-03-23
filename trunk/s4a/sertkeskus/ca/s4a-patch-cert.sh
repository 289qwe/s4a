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

ask_capassword

CACERTFILE="cacert.pem"
NEWCACERT="$TEMP_DIR/$CACERTFILE"
cp "$CA_CERT" "$NEWCACERT"

NEWCERTFILE="s4apatch.pem"

NEWREQ="$1"
NEWCERT="$TEMP_DIR/$NEWCERTFILE"
NEWTAR="$TEMP_DIR/s4apatch.tgz"
rm -f "$NEWCERT" "$NEWTAR"

$S4A_CA_OPENSSL ca -config $CONFIG -in $NEWREQ -out $NEWCERT -extensions patch_cert -passin file:"$S4A_CURRENT_PASS"

tar -C $TEMP_DIR -czf $NEWTAR "$NEWCERTFILE" "$CACERTFILE"
WEBSERVDIR="$CA_DIR/localcert"

if [ ! -d "$WEBSERVDIR" ];
then
	mkdir "$WEBSERVDIR"
fi

rm "$NEWCACERT"
mv "$NEWCERT" "$WEBSERVDIR/$NEWCERTFILE"
mv "$NEWTAR" "$OUTPUT_DIR"

echo ""
echo "created successfully s4apatch certificate to $OUTPUT_DIR"
echo ""

exit 0
