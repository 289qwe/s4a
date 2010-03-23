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

mount_usb
check_end usb
umount_usb
