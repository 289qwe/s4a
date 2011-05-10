#!/bin/sh

# /* Copyright (C) 2011, Cybernetica AS, http://www.cybernetica.eu/ */


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
           (echo "`cat $VAR_HOSTNAME` $EMAILPARAMS `date`:";
           echo "$ETH: `cat $VAR_IFACE`";
           echo "$TRUNK: `cat $VAR_TRUNKIFACES`";
           echo "$IP2: `cat $VAR_IP_ADDRESS`";
           echo "$IP5: `cat $VAR_HOSTNAME`";
           echo "$IP6: `cat $VAR_DOMAIN`";
           echo "$IP3: `cat $VAR_SUBNET_MASK`";
           echo "$IP4: `cat $VAR_DEFAULT_GATEWAY`";
           echo "$IP7: `cat $VAR_NAMESERVERS`";
           echo "$NTP: `cat $VAR_NTP_SERVER`";
           echo "$SNMP: `cat $VAR_SNMP_SERVER`";
           #echo "$SNMPCOMMUNITY: `cat $VAR_RO_COMMUNITY`";
           echo "$SNORT: `cat $VAR_LOCALNETS`";
           echo "$SYSLOG: `cat $VAR_SYSLOGSERVER`";
           echo "$CERT1: `cat $VAR_SHORTNAME`";
           echo "$CERT2: `cat $VAR_FULLNAME`";
           echo "$CERT3: `cat $VAR_ORGANISATION`";
           echo "$CERT4: `cat $VAR_CENTRALSERVER`";
           echo "$CERT5: `cat $VAR_SECONDCENTRAL`";
           echo "$SERIALNO: `cat $VAR_SERIALNUMBER`";
           echo "$VERSION: `cat $VAR_SOFTWARE_VERSION`";
           echo "$EMAILMSG: `cat $VAR_SMTP`";
           ) | mail -s "`cat $VAR_HOSTNAME`.`cat $VAR_DOMAIN` post"\
           `cat $VAR_ADMIN_EMAIL`
           $D --title "$TITLE" --msgbox "$EMAILSENT `cat $VAR_ADMIN_EMAIL`" 15 50;
         fi;;
    "5") rm -f /tmp/retemail
         exit 0
  esac
done
