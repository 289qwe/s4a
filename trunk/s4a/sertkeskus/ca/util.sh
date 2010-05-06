#! /bin/sh 

# /* Copyright (C) 2010, Cybernetica AS, http://www.cybernetica.eu/ */


init_s4a_ca() {
	init_binaries
	init_ca
	check_ca_directory
}

init_binaries() {

# It is assumed that cp, touch, mkdir, cut,
# cat and rm are in the path somewhere

	if [ "$S4A_CA_OPENSSL" = "" ]
	then
		S4A_CA_OPENSSL="openssl"
	fi
}

init_ca() {

	CA_DIR="$S4A_CA_BIN/cafiles"
	CONFIG="$S4A_CA_BIN/s4a-ca.cnf"
	BUNDLE_DIR="$S4A_CA_BIN/bundle"
	CERTS_DIR="$CA_DIR/certs"
	CRL_DIR="$CA_DIR/crl"
	NEW_CERTS_DIR="$CA_DIR/newcerts"
	PRIVATE_DIR="$CA_DIR/private"
	TEMP_DIR="$CA_DIR/temp"
	OUTPUT_DIR="$CA_DIR/output"
	DATABASE_FILE="$CA_DIR/index.txt"
	DATABASE_FILE_ATTR="$DATABASE_FILE.attr"
	SERIAL_FILE="$CA_DIR/serial"
	CA_CERT="$CA_DIR/cacert.pem"
	PRIV_KEY="$PRIVATE_DIR/cakey.pem"
	CRL_PEM="$CRL_DIR/crl.pem"

	S4A_NEW_PASS="/tmp/s4a-new-pass"
	S4A_CURRENT_PASS="/tmp/s4a-current-pass"
}

create_directory() {
	if [ "$1" = "" ]
	then
		echo "Usage: $0 <directory name>"
		exit 1
	fi
	
	echo "creating directory $1"
	mkdir -p $1
}

check_environment() {
	if [ -z "$CA_DIR" ]
	then
		echo "You must initialize CA_DIR variable to point to directory that"
		echo "will contain files used by CA."
		exit 1
	fi
}

clear_capassword() {
	if [ -e $S4A_CURRENT_PASS ]
	then
		rm -f $S4A_CURRENT_PASS
	fi

	if [ -e $S4A_NEW_PASS ]
	then
		rm -f $S4A_NEW_PASS
	fi
}

ask_capassword() {
	if [ -e $S4A_CURRENT_PASS ]
	then
		echo "Cannot continue - file $S4A_CURRENT_PASS exists"
		exit 1
	fi

	stty -echo
	echo -n "Enter CA password "
	read current
	echo
	stty echo
	echo "$current" >$S4A_CURRENT_PASS
}

ask_new_capassword() {
	if [ -e $S4A_NEW_PASS ]
	then
		echo "Cannot continue - file $S4A_NEW_PASS exists"
		exit 1
	fi

	stty -echo
	echo -n "Enter new CA password "
	read new1
	echo
	echo -n "Enter new CA password once more "
	read new2
	echo
	stty echo

	if [ "$new1" != "$new2" ]
	then
		echo "Two password entries differ. Password not changed!"
		exit 1
	fi

	echo "$new1" >$S4A_NEW_PASS
}


check_capassword() {
	if [ -z "$CAPASSWORD" ]
	then
		echo "You must initialize CAPASSWORD variable to point CA password"
		exit 1
	fi
}


check_ca_directory() {

	check_environment

	if [ ! -d $CA_DIR ]
	then
		echo "file named $CA_DIR does not exists."
	fi
}

create_ca_directory() {

	check_environment

	if [ -f "$CA_DIR" ]
	then
		echo "file named $CA_DIR already exists."
		exit 1;
	fi

	if [ -d "$CA_DIR" ]
	then
		EXT=`date "+%s"`
		sleep 1
		OLDDIR="$CA_DIR.$EXT"
		if [ -d "$CA_DIR" ]
		then
		 	mv "$CA_DIR" "$OLDDIR"
			echo "directory $CA_DIR already exists, renamed to $OLDDIR"
		fi
	fi  
	
	create_directory $CA_DIR
}

convert_crl() {
	$S4A_CA_OPENSSL crl -inform PEM -in $1 -outform DER -out $2 
}

convert_cert() {
	$S4A_CA_OPENSSL x509 -inform PEM -in $1 -outform DER -out $2 
}
