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

smenu=1
while [ 0 ]; do
  $D --title "$TITLE" --default-item "$smenu" --menu "$ITEM6" 15 50 4 1 "$SNMP" 2 "$SNMPCOMMUNITY" 3 "$IP9" 4 "$IP10" 2>/tmp/retsnmp
  ret=$?
  cancel_pressed $ret

  RETSNMP="`cat /tmp/retsnmp`"
  smenu=$RETSNMP
  case "$RETSNMP" in
    "1") ask_value "$SNMPASK" "$SNMPADDR" "$IPEXP" "$FAILIP";;
    "2") ask_value "$SNMPCOMMUNITYASK" "$ROCOMMUNITY" "$TEXTEXP" "$FAILTEXT";;
    "3") ret=0
         error=$MAKEFAIL
         verify_var "$VAR_SNMP_SERVER";
         if [ $? -ne 0 ]; then
           error="$error\n$VARNOTSET $SNMP"
           ret=1
         fi
         verify_var "$VAR_RO_COMMUNITY"
         if [ $? -ne 0 ]; then
           error="$error\n$VARNOTSET $SNMPCOMMUNITY"
           ret=1
         fi

         if [ $ret -ne 0 ]; then
           $D --title "$TITLE" --msgbox "$error" 15 80
           unset error
         else
           make_conf monitoring
         fi;;
    "4") rm -f /tmp/retsnmp
         exit 0
  esac
done


