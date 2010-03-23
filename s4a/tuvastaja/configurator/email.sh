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

# This is script for email-settings

emenu=1
while [ 0 ]; do
  $D --title "$TITLE" --default-item "$emenu" --menu "$ITEM2" 15 50 5 1 "$EMAIL1" 2 "$EMAIL2" 3 "$IP9"\
  4 "$EMAIL3" 5 "$IP10" 2>/tmp/retemail
  ret=$?
  cancel_pressed $ret

  RETEMAIL="`cat /tmp/retemail`"
  emenu=$RETEMAIL
  case "$RETEMAIL" in
    "1") ask_value "$EMAIL1ASK" "$ADMINMAIL" "$EMAILEXP" "$FAILEMAIL";;
    "2") ask_value "$EMAIL2ASK" "$SMTPADDR" "$ANYEXP" "$FAILTEXT";;
    "3") ret=0
         error=$MAKEFAIL
         verify_var "$VAR_ADMIN_EMAIL"
         if [ $? -ne 0 ]; then
           error="$error\n$VARNOTSET $EMAIL"
           ret=1
         fi
         verify_var "$VAR_SMTP";
         if [ $? -ne 0 ]; then
           error="$error\n$VARNOTSET $EMAIL2"
           ret=1
         fi

         if [ $ret -ne 0 ]; then
           $D --title "$TITLE" --msgbox "$error" 15 80
           unset error
         else
           make_conf email
         fi;; 
    "4") ret=0
         error=$MAILFAIL
         verify_var "$VAR_SMTP";
         if [ $? -ne 0 ]; then
           error="$error\n$VARNOTSET $EMAIL2"
           ret=1
         fi

         if [ $ret -ne 0 ]; then
           $D --title "$TITLE" --msgbox "$error" 15 80
           unset error
         else
           (echo "`cat $VARDIR/$HOSTNAME` $EMAILPARAMS `date`:";
           echo "$ETH: `cat $VARDIR/$IFACE`";
           echo "$TRUNK: `cat $VARDIR/$TRUNKIFACES`";
           echo "$IP2: `cat $VARDIR/$IPADDR`";
           echo "$IP5: `cat $VARDIR/$HOSTNAME`";
           echo "$IP6: `cat $VARDIR/$DOMAIN`";
           echo "$IP3: `cat $VARDIR/$SUBMASK`";
           echo "$IP4: `cat $VARDIR/$GATEWAY`";
           echo "$IP7: `cat $VARDIR/$DNS`";
           echo "$NTP: `cat $VARDIR/$NTPADDR`";
           echo "$SNMP: `cat $VARDIR/$SNMPADDR`";
           echo "$SNMPCOMMUNITY: `cat $VARDIR/$ROCOMMUNITY`";
           echo "$SNORT: `cat $VARDIR/$LOCALNETS`";
           echo "$SYSLOG: `cat $VARDIR/$SYSLOGSERVER`";
           echo "$CERT1: `cat $VARDIR/$SHORTNAME`";
           echo "$CERT2: `cat $VARDIR/$LONGNAME`";
           echo "$CERT3: `cat $VARDIR/$ORG`";
           echo "$CERT4: `cat $VARDIR/$CENTRAL`";
           echo "$CERT5: `cat $VARDIR/$SECONDCENTRAL`";
           echo "$VERSION: `cat $VARDIR/$SOFTVER`";
           echo "$EMAILMSG: `cat $VARDIR/$SMTPADDR`";
           ) | mail -s "`cat $VARDIR/$HOSTNAME`.`cat $VARDIR/$DOMAIN` post"\
           `cat $VARDIR/$ADMINMAIL`
           $D --title "$TITLE" --msgbox "$EMAILSENT `cat $VARDIR/$ADMINMAIL`" 15 50;
         fi;;
    "5") rm -f /tmp/retemail
         exit 0
  esac
done
