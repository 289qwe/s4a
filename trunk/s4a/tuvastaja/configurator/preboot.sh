#!/bin/sh

# /* Copyright (C) 2010, Cybernetica AS, http://www.cybernetica.eu/ */


# This script will be exectued once - right after 
# the system install, before the first boot

if [ -z "$CONFROOT" ]; then
  CONFROOT=/var/www/tuvastaja/configurator
fi
if [ -z "$VARDIR" ]; then
  VARDIR=/var/www/tuvastaja/data/conf
fi

# Include functions
. $CONFROOT/functions.sh

check_first_install
if [ $? -eq 1 ]; then
  pmenu=1
  while [ 0 ]; do
    $D --title "$TITLE" --default-item "$pmenu" --menu "$MAINMENU" 15 80 2 \
    1 "$PRE1" 2 "$PRE2" 2>/tmp/retpremenu
    ret=$?
    cancel_pressed $ret

    RETPREMENU="`cat /tmp/retpremenu`"
    pmenu="$RETPREMENU"

    cd $CONFROOT
    case "$RETPREMENU" in
      "1") sh ip.sh "$PREBOOT" "preboot"
           exit 0;;
      "2") sh prerestore.sh
           if [ $? -eq 0 ]; then
             check_end
             if [ $? -ne 1 ]; then             
               make preboot version
               exit 0
             fi
           fi;;
    esac
  done
else
  cd $CONFROOT
  make preboot version
fi
