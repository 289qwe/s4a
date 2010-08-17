#!/bin/sh

# /* Copyright (C) 2010, Cybernetica AS, http://www.cybernetica.eu/ */

if [ -z "$CONFROOT" ]; then
  CONFROOT=/var/www/tuvastaja/configurator
fi
if [ -z "$VARDIR" ]; then
  VARDIR=/var/www/tuvastaja/data/conf
fi

CONFDIR=/var/www/tuvastaja/data/snort/conf
PREPROC=$CONFDIR/preprocessors.conf

# Include functions
. $CONFROOT/functions.sh

# Find out where we are storing the snort performance statistics if set
if ! grep -R -q "^preprocessor perfmonitor" $PREPROC; then
  # No info for droprate
  echo 0
  echo 0
  echo 0
  echo PreprocessorNotTurnedOn
  exit 1
fi

STATFILE=`grep -R -A 1 "^preprocessor perfmonitor" $PREPROC | grep file | sed -e 's/.*file \(.*\)/\1/g' | cut -f 1`

if [ -z $STATFILE ]; then
  # No stat file set
  echo 0
  echo 0
  echo 0
  echo CantGetStatFileLocation
  exit 1
fi
if [ ! -s $STATFILE ]; then
  # No file
  echo 0
  echo 0
  echo 0
  echo StatFileDoesntExist
  exit 1
fi

DROPRATE=`tail -1 $STATFILE | cut -d , -f 2`

# For MRTG
echo $DROPRATE
echo 0
echo 0
echo SnortDropRate
