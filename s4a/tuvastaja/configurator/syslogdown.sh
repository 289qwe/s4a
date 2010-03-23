#!/bin/sh

# /* Copyright (C) 2010, Cybernetica AS, http://www.cybernetica.eu/ */

if [ -z "$CONFROOT" ]; then
  CONFROOT=/var/www/tuvastaja/configurator
fi
# Check if syslogd is running
# Include functions
. $CONFROOT/functions.sh

if_running syslogd _syslogd
sleep 1 
