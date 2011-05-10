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

# Show defined values

echo "$SHOWALL" > /tmp/show.out
echo "\n$ETH: `cat $VAR_IFACE`" >> /tmp/show.out
echo "$TRUNK: `cat $VAR_TRUNKIFACES`" >> /tmp/show.out
echo "$IP2: `cat $VAR_IP_ADDRESS`" >> /tmp/show.out
echo "$IP3: `cat $VAR_SUBNET_MASK`" >> /tmp/show.out
echo "$IP4: `cat $VAR_DEFAULT_GATEWAY`" >> /tmp/show.out
echo "$IP5: `cat $VAR_HOSTNAME`" >> /tmp/show.out
echo "$IP6: `cat $VAR_DOMAIN`" >> /tmp/show.out
echo "$IP7: `cat $VAR_NAMESERVERS`" >> /tmp/show.out
echo "$EMAIL1: `cat $VAR_ADMIN_EMAIL`" >> /tmp/show.out
echo "$EMAIL2: `cat $VAR_SMTP`" >> /tmp/show.out
echo "$NTP: `cat $VAR_NTP_SERVER`" >> /tmp/show.out
echo "$SNMP: `cat $VAR_SNMP_SERVER`" >> /tmp/show.out
#echo "$SNMPCOMMUNITY: `cat $VAR_RO_COMMUNITY`" >> /tmp/show.out
echo "$SYSLOG: `cat $VAR_SYSLOGSERVER`" >> /tmp/show.out
echo "$SNORT: `cat $VAR_LOCALNETS`" >> /tmp/show.out
echo "$CERT1: `cat $VAR_SHORTNAME`" >> /tmp/show.out
echo "$CERT2: `cat $VAR_FULLNAME`" >> /tmp/show.out
echo "$CERT3: `cat $VAR_ORGANISATION`" >> /tmp/show.out
echo "$CERT4: `cat $VAR_CENTRALSERVER`" >> /tmp/show.out
echo "$CERT5: `cat $VAR_SECONDCENTRAL`" >> /tmp/show.out
echo "$SERIALNO: `cat $VAR_SERIALNUMBER`" >> /tmp/show.out
echo "$VERSION: `cat $VAR_SOFTWARE_VERSION`" >> /tmp/show.out
echo "\n$SHOWINFO" >> /tmp/show.out

$D --title "$TITLE" --textbox /tmp/show.out 40 100
rm -rf /tmp/show.out
exit 0
