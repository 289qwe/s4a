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
  $D --title "$TITLE" --menu "$SNMP1" 15 50 2 1 "$YES" 2 "$NO" 2>/tmp/retyesno
  ret=$?
  cancel_pressed $ret

  if [ ! -s $VAR_SNMP_SERVER ]; then
    echo "127.0.0.1" > $VAR_SNMP_SERVER
  fi

  RETYESNO="`cat /tmp/retyesno`"
  case "$RETYESNO" in
    "1") ask_value "$SNMPASK" "$SNMPADDR" "$IPEXP" "$FAILIP"
         if [ $? -ne 0 ]; then
           return 1
         fi
         ret=0
         error=$MAKEFAIL
         verify_var "$VAR_SNMP_SERVER";
         if [ $? -ne 0 ]; then
           error="$error\n$VARNOTSET $SNMP"
           ret=1
         fi

         if [ $ret -ne 0 ]; then
           $D --title "$TITLE" --msgbox "$error" 15 80
           unset error
         else
           make_conf monitoring
         fi
         rm -f /tmp/retyesno
         exit 0;;
    "2") echo "127.0.0.1" > $VAR_SNMP_SERVER 
         #echo "$NOSYSLOG" > $VAR_RO_COMMUNITY
         make_conf monitoring
         rm -f /tmp/retyesno
         exit 0;;
  esac
done
