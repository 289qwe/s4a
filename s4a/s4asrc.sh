#!/bin/sh

# Copyright (C) 2010, Cybernetica AS, http://www.cybernetica.eu/

PWD=`pwd`
ROOT=$PWD
NAME=s4a-src

VER=4.6.1

ARCHIVE=$NAME-$VER.tar.gz

# Delete old archive, if exists
if [ -f $ARCHIVE ]; then
  rm -rf $ARCHIVE
fi

echo Creating $ARCHIVE
echo Adding the following folders and files:
cd $ROOT/
tar czvf $ROOT/$ARCHIVE s4a/* --exclude-vcs 
if [ $? -eq 0 ]; then
  echo "Created $ARCHIVE. Done"
else
  echo "Problems creating $ARCHIVE"
fi
