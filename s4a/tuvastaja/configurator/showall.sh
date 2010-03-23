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

# Show defined values

echo "$SHOWALL" > /tmp/show.out
echo "\n$ETH: `cat $VARDIR/$IFACE`" >> /tmp/show.out
echo "$TRUNK: `cat $VARDIR/$TRUNKIFACES`" >> /tmp/show.out
echo "$IP2: `cat $VARDIR/$IPADDR`" >> /tmp/show.out
echo "$IP3: `cat $VARDIR/$SUBMASK`" >> /tmp/show.out
echo "$IP4: `cat $VARDIR/$GATEWAY`" >> /tmp/show.out
echo "$IP5: `cat $VARDIR/$HOSTNAME`" >> /tmp/show.out
echo "$IP6: `cat $VARDIR/$DOMAIN`" >> /tmp/show.out
echo "$IP7: `cat $VARDIR/$DNS`" >> /tmp/show.out
echo "$EMAIL1: `cat $VARDIR/$ADMINMAIL`" >> /tmp/show.out
echo "$EMAIL2: `cat $VARDIR/$SMTPADDR`" >> /tmp/show.out
echo "$NTP: `cat $VARDIR/$NTPADDR`" >> /tmp/show.out
echo "$SNMP: `cat $VARDIR/$SNMPADDR`" >> /tmp/show.out
echo "$SNMPCOMMUNITY: `cat $VARDIR/$ROCOMMUNITY`" >> /tmp/show.out
echo "$SYSLOG: `cat $VARDIR/$SYSLOGSERVER`" >> /tmp/show.out
echo "$SNORT: `cat $VARDIR/$LOCALNETS`" >> /tmp/show.out
echo "$CERT1: `cat $VARDIR/$SHORTNAME`" >> /tmp/show.out
echo "$CERT2: `cat $VARDIR/$LONGNAME`" >> /tmp/show.out
echo "$CERT3: `cat $VARDIR/$ORG`" >> /tmp/show.out
echo "$CERT4: `cat $VARDIR/$CENTRAL`" >> /tmp/show.out
echo "$CERT5: `cat $VARDIR/$SECONDCENTRAL`" >> /tmp/show.out
echo "$VERSION: `cat $VARDIR/$SOFTVER`" >> /tmp/show.out
echo "\n$SHOWINFO" >> /tmp/show.out

$D --title "$TITLE" --textbox /tmp/show.out 40 100
rm -rf /tmp/show.out
exit 0
