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
echo "$ETH: `cat $VAR_IFACE`" >> /tmp/show.out
echo "$TRUNK: `cat $VAR_TRUNKIFACES`" >> /tmp/show.out
echo "$IP2: `cat $VAR_IP_ADDRESS`" >> /tmp/show.out
echo "$IP3: `cat $VAR_SUBNET_MASK`" >> /tmp/show.out
echo "$IP4: `cat $VAR_DEFAULT_GATEWAY`" >> /tmp/show.out
echo "$IP5: `cat $VAR_HOSTNAME`" >> /tmp/show.out
echo "$IP6: `cat $VAR_DOMAIN`" >> /tmp/show.out
echo "$IP7: `cat $VAR_NAMESERVERS`" >> /tmp/show.out

$D --title "$TITLE" --textbox /tmp/show.out 25 80
rm -rf /tmp/show.out
exit 0
