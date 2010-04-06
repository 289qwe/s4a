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

cd $CONFROOT
make http
crontab -l > /tmp/cronfile
if grep -q -R "^0 2 .*disk-cleanup.pl$" /tmp/cronfile; then
  sed -e 's/^0 2 \(.*disk-cleanup.pl$\)/0 2,8,14,20 \1/g' /tmp/cronfile > /tmp/cronfile.new
  crontab /tmp/cronfile.new
fi
rm -rf /var/www/conf/snort4all
rm -rf /tmp/cronfile*
