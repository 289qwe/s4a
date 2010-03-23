#!/bin/sh

# Copyright (C) 2010, Cybernetica AS, http://www.cybernetica.eu/

# See skript pakib paikamise failid kokku siia samma kataloogi
# nii, et need saaks CERT-ile anda oma paikade signeerimise keskkonna jaoks

ARCHIVE=s4a-patch.tgz

TMPROOT=s4a-patch
PWD=`pwd`
ROOT=$PWD

#Delete old archive, if exists
if [ -f $ARCHIVE ]
then rm -rf $ARCHIVE
fi

# Create temp folders
mkdir -p $ROOT/$TMPROOT

# Place files as needed
cd $ROOT/paikamine
cp genpatchkey.sh LOEMIND-BSD s4apatch.sh $ROOT/$TMPROOT/

echo Creating $ARCHIVE
echo Adding the following folders and files:
cd $ROOT
tar czvf $ARCHIVE $TMPROOT

# Remove temp files
rm -rf $ROOT/$TMPROOT

echo Done


