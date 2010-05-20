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

if [ ! -s $VAR_IFACE ]; then
  echo "No network interface configured"
  exit 1
fi
if [ ! -s $VAR_TRUNKIFACES ]; then
  echo "No trunk interfaces configured"
  exit 1
fi

NET=`cat $VAR_IFACE`
TRUNKS=`cat $VAR_TRUNKIFACES`
ALLNET="$NET $TRUNKS"

if [ -z $1 ]; then
  echo "Expecting network interface for argument"
  exit 1
fi

if ! echo "$ALLNET" | grep -q $1; then
  echo 0
  echo 0
  echo 0
  echo 0
  exit 1
fi

traffic $1
