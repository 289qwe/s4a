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

/var/www/tuvastaja/snort/start-stop-snort restart

TZ=`readlink /etc/localtime`
cd /var/www/etc
ln -sf "..$TZ" localtime
ln -sf $CONFROOT/static/httpd.conf /var/www/conf/httpd.conf
ln -sf /usr/local/share/examples/php5/php5.conf /var/www/conf/modules/php5.conf
ln -sf /usr/local/share/examples/php5/php.ini-recommended /var/www/conf/php.ini
apachectl stop > /dev/null
sleep 3
apachectl start > /dev/null

crontab -l > /tmp/cronfile.root
crontab -l -u _snort > /tmp/cronfile.snort

if grep -q -R "^.*disk-cleanup.pl$" /tmp/cronfile.root; then
  sed -e 's/^0 2,8,14,20 \(.*disk-cleanup.pl$\)/0 2-23\/6 \1/g' /tmp/cronfile.root > /tmp/cronfile.root.new
fi
if [ -s /tmp/cronfile.root.new ]; then
  mv /tmp/cronfile.root.new /tmp/cronfile.root
fi
if grep -q -R "^.*sendsignal$" /tmp/cronfile.root; then
  sed -e 's/^4,[0-9,]* \(.*sendsignal$\)/4-59\/5 \1/g' /tmp/cronfile.root > /tmp/cronfile.root.new
fi
if grep -q -R "^.*snortomatic$" /tmp/cronfile.snort; then
  sed -e 's/^\([0-4]\),[0-9,]* \(.*snortomatic$\)/\1-59\/5 \2/g' /tmp/cronfile.snort > /tmp/cronfile.snort.new
fi

crontab /tmp/cronfile.root.new
crontab -u _snort /tmp/cronfile.snort.new
rm -rf /tmp/cronfile*
rm -rf /var/www/tuvastaja/keygen/server*
