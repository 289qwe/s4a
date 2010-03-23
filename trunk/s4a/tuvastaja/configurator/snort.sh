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

ask_value "$SNORTASK" "$LOCALNETS" "$CIDREXP" "$FAILCIDR";
if [ $? -eq 0 ]; then
  ret=0
  error=$MAKEFAIL
  verify_var "$VAR_LOCALNETS";
  if [ $? -ne 0 ]; then
    error="$error\n$VARNOTSET $SNORT"
    ret=1
  fi
  verify_var "$VAR_TRUNKIFACES";
  if [ $? -ne 0 ]; then
    error="$error\n$VARNOTSET $TRUNK"
    ret=1
  fi

  if [ $ret -ne 0 ]; then
    $D --title "$TITLE" --msgbox "$error" 15 80
    unset error
  else
    make_conf snort
  fi
fi
