#!/bin/sh

# Copyright (C) 2010, Cybernetica AS, http://www.cybernetica.eu/

# See skript pakib keskserveri tarkvara failid kokku siia samma
# kataloogi nii, et see pakk tuleb toimetada sinna, kus toimub
# keskserveri bsd paki tegemine või kust ports selle alla suudab laadida.

PWD=`pwd`
ROOT=$PWD
CENTRE=s4a-centre

VER=`cat keskus/s4a-view/index.html | grep "^<head.*S4A keskus" | sed -e 's/^.* \([0-9\.]*\).*$/\1/g'`

ARCHIVE=$CENTRE-$VER.tar.gz

# Delete old archive, if exists
if [ -f $ARCHIVE ]; then
  rm -rf $ARCHIVE
fi

# Create temp folders
cd $ROOT
mkdir -p $CENTRE
cd $ROOT/keskus
cp -r conf confserv database keygen Makefile man s4ad s4a-draw s4a-view sigsupporter $ROOT/$CENTRE/

echo Creating $ARCHIVE
echo Adding the following folders and files:
cd $ROOT
tar czvf $ARCHIVE $CENTRE --exclude-vcs 
if [ $? -eq 0 ]; then
  rm -rf $ROOT/$CENTRE
  echo "Created $ARCHIVE. Done"
else
  rm -rf $ROOT/$CENTRE
  echo "Problems creating $ARCHIVE"
fi
