#!/bin/sh

# /* Copyright (C) 2010, Cybernetica AS, http://www.cybernetica.eu/ */


if [ -z "$CONFROOT" ]; then
  CONFROOT=/var/www/tuvastaja/configurator
fi
if [ -z "$VARDIR" ]; then
  VARDIR=/var/www/tuvastaja/data/conf
fi

. $CONFROOT/functions.sh

while [ 0 ]; do
  $D --title "$TITLE" --menu "$SECONDCERTCHOICE" 15 80 3 \
  1 "$YES" 2 "$NO" 3 "$NO. $DELETESECONDCERTS" 2>/tmp/retyesno
  ret=$?
  cancel_pressed $ret

  RETYESNO="`cat /tmp/retyesno`"
  case "$RETYESNO" in
    "1") sh keycert.sh secondary
         rm -f /tmp/retyesno
         exit 0;;
    "2") rm -f /tmp/retyesno
         exit 0;;
    "3") $D --title "$TITLE" --menu "$DELETECERTSWARNING" 15 80 2 \
         1 "$NO" 2 "$YES" 2>/tmp/retcertdelete
         ret=$?
         cancel_pressed $ret
         RETCERTDELETE="`cat /tmp/retcertdelete`"
         case "$RETCERTDELETE" in
           "1") exit 0;;
           "2") rm -rf /var/www/tuvastaja/data/cacerts2/*
                rm "$VAR_SECONDCENTRAL"
                rm -f /tmp/retyesno /tmp/retcertdelete
                exit 0;;
         esac;;
  esac
done
