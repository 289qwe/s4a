#!/bin/sh

# /* Copyright (C) 2010, Cybernetica AS, http://www.cybernetica.eu/ */

#This is main menu skript

#For testing only
#TESTROOT=/root/SVN/trunk/configurator
#TESTVAR=/root/SVN/trunk/configurator/var

CONFROOT=/var/www/tuvastaja/configurator
VARDIR=/var/www/tuvastaja/data/conf

if [ -n "$TESTROOT" ];
  then CONFROOT=$TESTROOT
fi
if [ -n "$TESTVAR" ];
  then VARDIR=$TESTVAR
fi

#Include functions
. $CONFROOT/functions.sh

export CONFROOT VARDIR

#Create variables folder if it doesn't exists
make_dir $VARDIR

#ctrl+c? dream on.
trap "" 2

mmenu=1
while [ 0 ]; do
  $D --title "$TITLE" --default-item "$mmenu" --menu "$MAINMENU" 23 70 14 1 "$ITEM1" \
  2 "$ITEM2" 3 "$ITEM3" 4 "$ITEM4" 5 "$ITEM5" 6 "$ITEM6" 7 "$ITEM7" 8 "$ITEM8" \
  9 "$ITEM9" 10 "$ITEM10" 11 "$ITEM11" 12 "$ITEM12" 13 "$ITEM13" 14 "$ITEM14" 2>/tmp/retmenu
  ret=$?
  cancel_pressed $ret
  
  RETMENU="`cat /tmp/retmenu`"
  mmenu="$RETMENU"
  
  cd $CONFROOT
  case "$RETMENU" in
    "1") sh ip.sh "$IP10" "net";;
    "2") sh mailaddress.sh;;
    "3") sh restore.sh;;
    "4") sh keycert.sh;;
    "5") sh secondcentral.sh;;
    "6") sh ntp.sh;;
    "7") sh monitoring.sh;;
    "8") sh snort.sh;;
    "9") sh syslog.sh;;
    "10") sh password.sh;;
    "11") sh showall.sh;;
    "12") sh backup.sh;;
    "13") sh destroy.sh;;
    "14") check_end exit;;
  esac
done
