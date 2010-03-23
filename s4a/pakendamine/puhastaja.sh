#!/bin/sh

# /* Copyright (C) 2010, Cybernetica AS, http://www.cybernetica.eu/ */


# See skript puhastab vastava projekti ehitusasjad.
# Argumendiks soovitakse paketinime

# Paketid
CA="s4a-ca"
CEN="s4a-centre"
DET="s4a-detector"
RUL="s4a-rulesm"

usage()
{
  echo "Kasutus: $0 $CA|$CEN|$DET|$RUL"
}

clean()
{
  PACKETTE=$1
  cd $PACKETTE
  make clean
  make clean=dist
  make clean=plist
  make clean=package
  cd ..
}

if [ -z $1 ]; then
  usage
  exit 1
fi

case $1 in
  "$CA" ) clean $CA;;
  "$CEN" ) clean $CEN;;
  "$DET" ) clean $DET;;
  "$RUL" ) clean $RUL;;
  * ) usage
esac
