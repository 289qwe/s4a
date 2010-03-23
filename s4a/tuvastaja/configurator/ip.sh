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

RETURN_TEXT="$1"
MAKE_TARGET="$2"

# This is script for IP-settings

trap "" 2

imenu=1
while [ 0 ]; do
  $D --title "$TITLE" --default-item "$imenu" --menu "$ITEM1" 18 60 10 1 "$IP1" 2 "$IP2" 3 \
  "$IP3" 4 "$IP4" 5 "$IP5" 6 "$IP6" 7 "$IP7" 8 "$IP8" 9 "$IP9" 10 "$RETURN_TEXT" 2>/tmp/retip
  ret=$?
  cancel_pressed $ret

  RETIP="`cat /tmp/retip`"
  imenu=$RETIP
  case "$RETIP" in
    "1") sh devip.sh;;
    "2") ask_value "$IP2ASK" "$IPADDR" "$IPEXP" "$FAILIP";; 
    "3") ask_value "$IP3ASK" "$SUBMASK" "$IPEXP" "$FAILIP";; 
    "4") ask_value "$IP4ASK" "$GATEWAY" "$IPEXP" "$FAILIP";; 
    "5") ask_value "$IP5ASK" "$HOSTNAME" "$TEXTEXP" "$FAILTEXT";;
    "6") ask_value "$IP6ASK" "$DOMAIN" "$DOMAINEXP" "$FAILDOMAIN";;
    "7") ask_value "$IP7ASK" "$DNS" "$IPEXP" "$FAILIP";;
    "8") sh showsettings.sh;; 
    "9") ret=0
         error=$MAKEFAIL
         verify_var "$VAR_IFACE"
         if [ $? -ne 0 ]; then
           error="$error\n$VARNOTSET $ETH"
           ret=1
         fi
         verify_var "$VAR_TRUNKIFACES"
         if [ $? -ne 0 ]; then
           error="$error\n$VARNOTSET $TRUNK"
           ret=1
         fi
         verify_var "$VAR_IP_ADDRESS"
         if [ $? -ne 0 ]; then
           error="$error\n$VARNOTSET $IP2"
           ret=1
         fi
         verify_var "$VAR_SUBNET_MASK"
         if [ $? -ne 0 ]; then
           error="$error\n$VARNOTSET $IP3"
           ret=1
         fi
         verify_var "$VAR_DEFAULT_GATEWAY"
         if [ $? -ne 0 ]; then
           error="$error\n$VARNOTSET $IP4"
           ret=1
         fi
         verify_var "$VAR_HOSTNAME"
         if [ $? -ne 0 ]; then
           error="$error\n$VARNOTSET $IP5"
           ret=1
         fi
         verify_var "$VAR_DOMAIN"
         if [ $? -ne 0 ]; then
           error="$error\n$VARNOTSET $IP6"
           ret=1
         fi
         verify_var "$VAR_NAMESERVERS"
         if [ $? -ne 0 ]; then
           error="$error\n$VARNOTSET $IP7"
           ret=1
         fi

         if [ $ret -ne 0 ]; then
           $D --title "$TITLE" --msgbox "$error" 15 80
           unset error
         else
            make_conf $MAKE_TARGET
         fi;;
    "10") rm -f /tmp/retip
          rm -f /tmp/retdevip
          exit 0 ;;
  esac
done
