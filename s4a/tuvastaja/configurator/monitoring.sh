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

  if [ ! -s $VARDIR/$SNMPADDR ]; then
    echo "127.0.0.1" > $VARDIR/$SNMPADDR
  fi

  RETYESNO="`cat /tmp/retyesno`"
  case "$RETYESNO" in
    "1") if [ ! -s $VARDIR/$SNMPADDR ]; then
           echo "127.0.0.1" > $VARDIR/$SNMPADDR
         fi
         sh snmp.sh
         rm -rf /tmp/retyesno
         exit 0;;
    "2") echo "127.0.0.1" > $VARDIR/$SNMPADDR 
         echo "$NOSYSLOG" > $VARDIR/$ROCOMMUNITY
         make_conf monitoring
         rm -rf /tmp/retyesno
         exit 0;;
  esac
done
