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
create_ca_directory

ENC_KEY="$TEMP_DIR/cakeyencrypted.pem"
CA_REQ="$TEMP_DIR/cacertreq.pem"

create_directory $CERTS_DIR
create_directory $CRL_DIR
create_directory $NEW_CERTS_DIR
create_directory $PRIVATE_DIR
create_directory $TEMP_DIR
create_directory $OUTPUT_DIR

ask_new_capassword

echo "creating index to $DATABASE_FILE"
touch $DATABASE_FILE

echo "generating key $PRIV_KEY"
$S4A_CA_OPENSSL req -sha512 -new -newkey rsa:4096 -keyout $ENC_KEY -config $CONFIG -out $CA_REQ -nodes -subj '/C=EE/CN=S4A CA'
$S4A_CA_OPENSSL rsa -in $ENC_KEY -out $PRIV_KEY  -aes256  -passout file:"$S4A_NEW_PASS"
rm $ENC_KEY

echo "signing CA certificate $CA_CERT"
$S4A_CA_OPENSSL x509 -req -days 1827 -signkey $PRIV_KEY -passin file:"$S4A_NEW_PASS" -in $CA_REQ -out $CA_CERT -sha512 -extfile $CONFIG -extensions v3_ca

echo "creating serial number file $SERIAL_FILE"
$S4A_CA_OPENSSL x509 -CA $CA_CERT -CAcreateserial -CAserial $SERIAL_FILE \
	-CAkey $PRIV_KEY -passin file:"$S4A_NEW_PASS" -noout -req -in $CA_REQ
rm $CA_REQ

echo "unique_subject = no" > $DATABASE_FILE_ATTR

echo ""
echo "CA created successfully into the $CA_DIR directory"
echo ""

exit 0
