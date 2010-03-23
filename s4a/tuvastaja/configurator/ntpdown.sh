#!/bin/sh

# /* Copyright (C) 2010, Cybernetica AS, http://www.cybernetica.eu/ */

if [ -z "$CONFROOT" ]; then
  CONFROOT=/var/www/tuvastaja/configurator
fi
# Check if ntpd is running
# Include functions
. $CONFROOT/functions.sh

if_running ntpd _ntp
