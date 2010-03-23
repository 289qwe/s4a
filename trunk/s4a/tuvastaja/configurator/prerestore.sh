#!/bin/sh

# /* Copyright (C) 2010, Cybernetica AS, http://www.cybernetica.eu/ */


if [ -z "$CONFROOT" ]; then
  CONFROOT=/var/www/tuvastaja/configurator
fi
if [ -z "$VARDIR" ]; then
  VARDIR=/var/www/tuvastaja/data/conf
fi

# Include functions
. $CONFROOT/functions.sh

# Some neccessary variables
CERTDIR1=/var/www/tuvastaja/data/cacerts
CERTDIR2=/var/www/tuvastaja/data/cacerts2
TARNAME1=`echo $CERTDIR1 | sed 's/^.*\/\([a-z0-9]*\)/\1/'`.tgz
TARNAME2=`echo $CERTDIR2 | sed 's/^.*\/\([a-z0-9]*\)/\1/'`.tgz

prmenu=1
while [ 0 ]; do
  $D --title "$TITLE" --default-item "$prmenu" --menu "$PRE2" 15 80 4 \
  1 "$ITEM3" 2 "$PRIMCENTRALRESTORE" 3 "$SECCENTRALRESTORE" 4 "$PREBOOT" 2>/tmp/retrestoremenu
  ret=$?
  cancel_pressed $ret

  RETRESTOREMENU="`cat /tmp/retrestoremenu`"
  prmenu=$RETRESTOREMENU  

  case "$RETRESTOREMENU" in
    "1") sh restore.sh;;
    "2") sh certrestore.sh "$TARNAME1" "$CERTDIR1";;
    "3") sh certrestore.sh "$TARNAME2" "$CERTDIR2" "secondary";;
    "4") rm -f /tmp/ret*
         exit 0;;
  esac
done
