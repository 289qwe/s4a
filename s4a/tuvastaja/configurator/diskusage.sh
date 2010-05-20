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
ROOT=`df | grep /$ | awk '{printf("%s\n",$5);}' | sed -e 's/%//g'`
DATA=`df | grep data$ | awk '{printf("%s\n",$5);}' | sed -e 's/%//g'`

# For MRTG
echo $ROOT
echo $DATA
echo 0
echo diskUsage
