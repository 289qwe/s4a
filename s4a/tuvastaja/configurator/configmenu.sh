#!/bin/sh

# /* Copyright (C) 2010, Cybernetica AS, http://www.cybernetica.eu/ */

# This is main menu skript

# For testing only
# TESTROOT=/root/SVN/trunk/configurator
# TESTVAR=/root/SVN/trunk/configurator/var

CONFROOT=/var/www/tuvastaja/configurator
VARDIR=/var/www/tuvastaja/data/conf

if [ -n "$TESTROOT" ];
  then CONFROOT=$TESTROOT
fi
if [ -n "$TESTVAR" ];
  then VARDIR=$TESTVAR
fi

# Include functions
. $CONFROOT/functions.sh

export CONFROOT VARDIR

# Create variables folder if it doesn't exists
make_dir $VARDIR

# ctrl+c? dream on.
trap "" 2

if [ ! -e /root/.firstboot ]; then
  check_first_install
  if [ $? -eq 1 ]; then
    mmenu=1
    while [ 0 ]; do
    $D --title "$TITLE" --default-item "$mmenu" --menu "$MAINMENU" 23 70 14 1 "$ITEM2" \
    2 "$ITEM3" 3 "$ITEM4" 4 "$ITEM5" 5 "$ITEM6" 6 "$ITEM7" 7 "$ITEM8" 8 "$ITEM9" \
    9 "$ITEM10" 10 "$ITEM11" 11 "$ITEM12" 12 "$ITEM13" 13 "$IP10" 14 "$ITEM14" 2>/tmp/retmenu
    ret=$?
    cancel_pressed $ret
    
    RETMENU="`cat /tmp/retmenu`"
    mmenu="$RETMENU"
    
    cd $CONFROOT
    case "$RETMENU" in
      "1") sh mailaddress.sh;;
      "2") sh restore.sh;;
      "3") sh keycert.sh;;
      "4") sh secondcentral.sh;;
      "5") sh ntp.sh;;
      "6") sh monitoring.sh;;
      "7") sh snort.sh;;
      "8") sh syslog.sh;;
      "9") sh password.sh;;
      "10") sh showall.sh;;
      "11") sh backup.sh;;
      "12") sh destroy.sh;;
      "13") sh menu.sh
            return 0;;
      "14") check_end exit;;
    esac
    done
  else 
    mmenu=1
    while [ 0 ]; do
    $D --title "$TITLE" --default-item "$mmenu" --menu "$MAINMENU" 13 70 4 1 "$ITEM10" \
    2 "$ITEM11" 3 "$IP10" 4 "$ITEM14" 2>/tmp/retmenu
    ret=$?
    cancel_pressed $ret

    RETMENU="`cat /tmp/retmenu`"
    mmenu="$RETMENU"

    cd $CONFROOT
    case "$RETMENU" in
      "1") sh password.sh;;
      "2") sh showall.sh;;
      "3") sh menu.sh
           return 0;;
      "4") check_end exit;;
    esac
    done
  fi
else
  sh menu.sh
  return 0
fi 
