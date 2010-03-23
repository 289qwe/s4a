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

while [ 0 ]; do
  $D --title "$TITLE" --menu "$IFEMAIL" 15 50 2 1 "$YES" 2 "$NO" 2>/tmp/retyesno
  ret=$?
  cancel_pressed $ret

  if [ ! -s $VARDIR/$ADMINMAIL ]; then
    echo "$NOSYSLOG" > $VARDIR/$ADMINMAIL
  fi

  RETYESNO="`cat /tmp/retyesno`"
  case "$RETYESNO" in
    "1") sh email.sh	
         rm -rf /tmp/retyesno
         exit 0;;
    "2") echo "$NOSYSLOG" > $VARDIR/$ADMINMAIL
         echo "127.0.0.1" > $VARDIR/$SMTPADDR
         make_conf email
         pkill sendmail
         rm -rf /tmp/retyesno
         exit 0;;
  esac
done
