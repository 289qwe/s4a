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
  $D --title "$TITLE" --menu "$SYSLOG1" 15 70 2 1 "$YES" 2 "$NO" 2>/tmp/retyesno
  ret=$?
  cancel_pressed $ret

  if [ ! -s $VARDIR/$SYSLOGSERVER ]; then
    echo "$NOSYSLOG" > $VARDIR/$SYSLOGSERVER
  fi

  RETYESNO="`cat /tmp/retyesno`"
  case "$RETYESNO" in
    "1") ask_value "$SYSLOGASK" "$SYSLOGSERVER" "$IPEXP" "$FAILIP"
         if [ $? -ne 0 ]; then
           return 1
         fi
         ret=0
         error=$MAKEFAIL
         verify_var "$VAR_SYSLOGSERVER";
         if [ $? -ne 0 ]; then
           error="$error\n$VARNOTSET $SYSLOG"
           ret=1
         fi

         if [ $ret -ne 0 ]; then
           $D --title "$TITLE" --msgbox "$error" 15 80
           unset error
         else
           make_conf syslog
         fi
         rm -rf /tmp/retyesno
         exit 0;;
    "2") echo "$NOSYSLOG" > $VARDIR/$SYSLOGSERVER
         make_conf syslog
         rm -rf /tmp/retyesno
         exit 0;;
  esac
done
