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

result=0

mount_usb

CONF=`find $MOUNTDIR -maxdepth 1 -name configuration.tgz`

if [ -n "$CONF" ]; then
  tar tzf $CONF -C / $VARIABLES
  if [ $? -eq 0 ]; then
    tar xzf $CONF -C / $VARIABLES
    $D --title "$TITLE" --msgbox "$MOUNTSUCC" 15 50
    result=1
  else
    $D --title "$TITLE" --msgbox "$RESTOREFAIL" 15 50
  fi
else
  $D --title "$TITLE" --msgbox "$RESTOREFAIL" 15 50
fi

umount_usb

if [ $result -ne 1 ]; then
  exit 1
fi

if [ -e /root/.firstapache ]; then
  make_conf postupd
fi
