#!/bin/sh

# /* Copyright (C) 2010, Cybernetica AS, http://www.cybernetica.eu/ */


if [ -z "$CONFROOT" ]; then
  CONFROOT=/var/www/tuvastaja/configurator
fi

# Include functions
. $CONFROOT/functions.sh

# This is script for changing passwords
HTDIGEST=/var/www/tuvastaja/data/apache/tuvastajadigest

pmenu=1
while [ 0 ]; do
  $D --title "$TITLE" --default-item "$pmenu" --menu "$ITEM10" 13 70 4 1 "$PASS1" 2 "$PASS2" 3 "$PASS3" 4 "$IP10" 2>/tmp/retpass
  ret=$?
  cancel_pressed $ret

  RETPASS="`cat /tmp/retpass`"
  pmenu=$RETPASS
  case "$RETPASS" in
    "1") create_user admin
         user mod -G wheel admin
         if ! grep -q -R admin /etc/sudoers; then
           echo "admin    ALL=(ALL) SETENV: ALL" >> /etc/sudoers
         fi
         passwd admin;;
    "2") passwd root;;
    "3") if [ -f $HTDIGEST ]; then
           htdigest $HTDIGEST tuvastaja webadmin
         else
           htdigest -c $HTDIGEST tuvastaja webadmin
         fi;;
    "4") rm -f /tmp/retpass
         exit 0;;
  esac
done
