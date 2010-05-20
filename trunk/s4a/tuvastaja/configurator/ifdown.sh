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

# Check if network is up or not
LINK=`cat $VAR_IFACE`

CONFIG=/tmp/ifconfig
ifconfig -a > $CONFIG

if grep -q -R "active" $CONFIG; then
  ifconfig $LINK down
  for i in `ifconfig -a | grep trunkport | sed 's/.*trunkport \([a-z0-9]*\).*/\1/'`; do
    ifconfig $i down
    ifconfig trunk0 -trunkport $i
  done
  sleep 3 
fi
rm -f $CONFIG
