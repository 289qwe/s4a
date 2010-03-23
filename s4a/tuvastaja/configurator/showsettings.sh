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

echo "$SHOWMSG" > /tmp/show.out
echo "$ETH: `cat $VARDIR/$IFACE`" >> /tmp/show.out
echo "$TRUNK: `cat $VARDIR/$TRUNKIFACES`" >> /tmp/show.out
echo "$IP2: `cat $VARDIR/$IPADDR`" >> /tmp/show.out
echo "$IP3: `cat $VARDIR/$SUBMASK`" >> /tmp/show.out
echo "$IP4: `cat $VARDIR/$GATEWAY`" >> /tmp/show.out
echo "$IP5: `cat $VARDIR/$HOSTNAME`" >> /tmp/show.out
echo "$IP6: `cat $VARDIR/$DOMAIN`" >> /tmp/show.out
echo "$IP7: `cat $VARDIR/$DNS`" >> /tmp/show.out

$D --title "$TITLE" --textbox /tmp/show.out 25 80
rm -rf /tmp/show.out
exit 0
