#!/bin/sh

# Copyright (C) 2010, Cybernetica AS, http://www.cybernetica.eu/

# See skript pakib sertifitseerimiskeskuse failid kokku siia samma
# kataloogi nii, et see pakk tuleb toimetada sinna, kus toimub
# s4a-ca bsd paki tegemine või kust ports selle alla suudab laadida.

PWD=`pwd`
ROOT=$PWD
CA=s4a-ca

VER=4.6.6

ARCHIVE=$CA-$VER.tar.gz

# Delete old archive, if exists
if [ -f $ARCHIVE ]; then
  rm -rf $ARCHIVE
fi

echo Creating $ARCHIVE
echo Adding the following folders and files:
cd $ROOT/sertkeskus
tar czvf $ARCHIVE Makefile ca man --exclude-vcs 
if [ $? -eq 0 ]; then
  mv $ROOT/sertkeskus/$ARCHIVE $ROOT/$ARCHIVE
  echo "Created $ARCHIVE. Done"
else
  echo "Problems creating $ARCHIVE"
fi
