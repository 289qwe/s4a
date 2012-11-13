#!/bin/sh

# /* Copyright (C) 2012, Cybernetica AS, http://www.cybernetica.eu/ */

if [ -z "$CONFROOT" ]; then
  CONFROOT=/var/www/tuvastaja/configurator
fi
if [ -z "$VARDIR" ]; then
  VARDIR=/var/www/tuvastaja/data/conf
fi

# Include functions
. $CONFROOT/functions.sh

STATSLOG=/var/www/tuvastaja/data/snort-logs/snortstats.log
if [ -f $STATSLOG  ]; then
  chown _snort $STATSLOG
fi
