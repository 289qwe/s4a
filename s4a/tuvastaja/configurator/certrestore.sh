#!/bin/sh

# /* Copyright (C) 2010, Cybernetica AS, http://www.cybernetica.eu/ */


if [ -z "$CONFROOT" ]; then
  CONFROOT=/var/www/tuvastaja/configurator
fi
if [ -z "$VARDIR" ]; then
  VARDIR="/var/www/tuvastaja/data/conf"
fi

# Include functions
. $CONFROOT/functions.sh

FILENAME="$1"
CERTDIR="$2"
SECONDARY="$3"

mount_usb
CONF=`find $MOUNTDIR -maxdepth 1 -name $FILENAME.enc`
if [ -n "$CONF" ]; then
  crypt d $CONF /tmp/$FILENAME
  if [ $? -ne 0 ]; then
    $D --title "$TITLE" --msgbox "$CERTRESTOREFAIL\n\n$WRONGPASS" 15 50
    rm /tmp/$FILENAME
    umount_usb
  else
    tar xzf /tmp/$FILENAME -C $CERTDIR
    rm /tmp/$FILENAME
    if [ "$SECONDARY" != "secondary" ]; then
      if [ -s $CERTDIR/$PATCHNAME ]; then
        cat $CERTDIR/$PATCHNAME >> /etc/ssl/pkgca.pem
        cat $CERTDIR/$CANAME >> /etc/ssl/pkgca.pem
        NOCERT=""
      else
        NOCERT="$NOPATCHCERT"
      fi
    else
      NOCERT=""
    fi
    perl $CONFROOT/getcertdata "$SECONDARY"

    # Make modification to nrpe.local.cfg with Centralserver
    cd $CONFROOT
    if [ -e /root/.firstapache ]; then
      make_conf nrpe
    fi
    $D --title "$TITLE" --msgbox "$CERTRESTORESUCC\n\n$NOCERT" 15 50
    umount_usb
    exit 0
  fi
else
  $D --title "$TITLE" --msgbox "$CERTRESTOREFAIL\n\n$NOCERTBACKUPFILE" 15 50
  umount_usb
  exit 1
fi
