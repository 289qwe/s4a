#!/bin/sh

# /* Copyright (C) 2010, Cybernetica AS, http://www.cybernetica.eu/ */


PATCHPARTS="spatch.level spatch.lst spatch.tar"

if [ ! -f spatch.level ]; then
	echo "spatch.level is missing" >&2
	exit 1
fi

if [ ! -f spatch.lst ]; then
	echo "spatch.lst is missing" >&2
	exit 1;
fi

# spatch.tar-iga pisut keemiat
# kui packages kataloog on olemas
# siis teeme nendest seal asuvatest failidest spatch.lst abil
# uue spatch.tar faili
if [ -d packages ]; then
	echo -n "Creating new spatch.tar .. " 
	cd packages
	tar cf ../spatch.tar `cat ../spatch.lst`
	if [ $? != 0 ]; then
		echo "Cannot create spatch.tar" >&2
		cd ..
		exit 1
	fi
	cd ..
	echo "OK"
else
	if [ ! -f spatch.tar ]; then
		echo "spatch.tar is missing" >&2
		exit 1
	fi
fi

IFS='.' read MAJOR MINOR PATCHLEVEL < spatch.level
if [ -z "$MAJOR" ]; then
	echo "Invalid spatch.level: no MAJOR version number"
	exit 1
fi
if [ -z "$MINOR" ]; then
	echo "Invalid spatch.level: no MINOR version number"
	exit 1
fi
if [ -z "$PATCHLEVEL" ]; then
	echo "Invalid spatch.level: no PATCHLEVEL version number"
	exit 1
fi
PATCHNAME="patch-$MAJOR.$MINOR.$PATCHLEVEL.tgz"


rm -f s4apatch.tar
tar cf s4apatch.tar ${PATCHPARTS}

if [ $? != 0 ]; then
	echo "unable to create patch body" >&2
	exit 1;
fi

rm -f $PATCHNAME
tar cfz $PATCHNAME s4apatch.tar

if [ $? -ne 0 ]; then
	echo "unable to pack patch" >&2
	exit 1;
fi

echo "OK"
	
exit 0;

