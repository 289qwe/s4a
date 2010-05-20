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

# Find out used memory
TOTAL=`sysctl -n hw.physmem`
FREE4KB=`vmstat -s | grep "pages free$" | sed -e 's/^ *\([0-9]*\).*/\1/g'`
FREE=$(($FREE4KB * 4096))
USED=$(($TOTAL - $FREE))

# For MRTG
echo $USED
echo $TOTAL
echo 0
echo memoryUsage
