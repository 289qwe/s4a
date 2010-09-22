#! /bin/sh

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
HOST=`cat $VAR_HOSTNAME`
DOM=`cat $VAR_DOMAIN`

if [ "$1" = "" ]; then
  echo "First argument should be certdirectory"
  exit 1
fi

if [ ! -d "$1" ]; then
  echo Directory "$1" doesn\'t exists
  exit 1
fi

mount_usb
ask_value "$KEY1ASK" "$LOCALORG" "^.*$" "$FAILTEXT"

CERTDIR="$1"
SUBJ="$HOST.$DOM"
ORG="`cat $VAR_LOCALORG`"
DISNAME="/C=EE/O=$ORG/CN=$SUBJ"
TEMPDIR="/tmp"
NEWKEY="$TEMPDIR/$SUBJ.key"
NEWREQ="$TEMPDIR/$SUBJ.req"

openssl req -sha512 -new -newkey rsa:2048 -keyout $NEWKEY -out $NEWREQ -nodes -subj "$DISNAME"
cp $NEWREQ "$MOUNTDIR"/
cp $NEWKEY "$CERTDIR"/$KEYNAME
rm -f $VAR_LOCALORG $NEWREQ $NEWKEY
umount_usb
$D --title "$TITLE" --msgbox "$REQSUCC" 15 50
