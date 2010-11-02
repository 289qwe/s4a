#!/bin/sh

# /* Copyright (C) 2010, Cybernetica AS, http://www.cybernetica.eu/ */


# See skript puhastab vastava projekti ehitusasjad.
# Argumendiks soovitakse paketinime

# Paketid

usage()
{
  echo "Kasutus: $0 paketinimi"
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

if [ ! -d $1 ]; then
  usage
  exit 1
fi

clean $1
