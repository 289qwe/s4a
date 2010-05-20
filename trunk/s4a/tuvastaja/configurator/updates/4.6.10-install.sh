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

DATADIR=/var/www/tuvastaja/data
if [ -s $DATADIR/snort-logs/siglevel ]; then
  mv $DATADIR/snort-logs/siglevel $DATADIR/snort/
fi
if [ -s $VARDIR/Ro_community.var ]; then
  rm $VARDIR/Ro_community.var
fi
if [ -s $VARDIR/Admin_Email.var ]; then
  touch $VARDIR/Admin_Email.var
fi
