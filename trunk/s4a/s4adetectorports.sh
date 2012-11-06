#!/bin/sh

# Copyright (C) 2012, Cybernetica AS, http://www.cybernetica.eu/

# See skript pakib tuvastaja failid kokku siia samma kataloogi
# nii, et see pakk tuleb toimetada sinna, kus toimub tuvastaja
# bsd paki tegemine või kust ports selle alla suudab laadida.

PWD=`pwd`
ROOT=$PWD
DET=s4a-detector

LEVEL=`grep "echo [0-9]* > \\$(PATCHLEVEL)" $ROOT/tuvastaja/configurator/Makefile | cut -d " " -f 2`
VER=5.2.$LEVEL

ARCHIVE=$DET-$VER.tar.gz

# Delete old archive, if exists
if [ -f $ARCHIVE ]; then
  rm -rf $ARCHIVE
fi

echo Creating $ARCHIVE
echo Adding the following folders and files:
cd $ROOT
tar czvf $ARCHIVE tuvastaja --exclude-vcs 
if [ $? -eq 0 ]; then
  echo "Created $ARCHIVE. Done"
else
  echo "Problems creating $ARCHIVE"
fi
