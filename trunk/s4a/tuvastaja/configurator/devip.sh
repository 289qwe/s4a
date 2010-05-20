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

# All network interfaces from ifconfig
IPDEVS=`ifconfig -a | grep 'BROADCAST' | grep -v  'trunk' | sed 's/^\(.*\)\: .*/\1/'`

count=1
for DEV in $IPDEVS; do
  IFSTAT=`ifconfig $DEV | grep 'status' | sed 's/^.*status: \(.*\)/\1/'`
  eval "dev$count=\"$DEV ($IFSTAT)\""
  eval "tmp$count=\"$DEV\""
  eval "tag$count=\"$count\"" 
  count=$(($count + 1))
done
count=$(($count - 1))

while true; do
  case $count in
    1) $D --title "$TITLE" --menu "$ETH" 15 50 10 $tag1 "$dev1" 2>/tmp/retdevip;;
    2) $D --title "$TITLE" --menu "$ETH" 15 50 10 $tag1 "$dev1" $tag2 "$dev2" 2>/tmp/retdevip;;
    3) $D --title "$TITLE" --menu "$ETH" 15 50 10 $tag1 "$dev1" $tag2 "$dev2" $tag3 "$dev3" 2>/tmp/retdevip;;
    4) $D --title "$TITLE" --menu "$ETH" 15 50 10 $tag1 "$dev1" $tag2 "$dev2" $tag3 "$dev3" $tag4 "$dev4" 2>/tmp/retdevip;;
    5) $D --title "$TITLE" --menu "$ETH" 15 50 10 $tag1 "$dev1" $tag2 "$dev2" $tag3 "$dev3" $tag4 "$dev4" $tag5 "$dev5" 2>/tmp/retdevip;;
    6) $D --title "$TITLE" --menu "$ETH" 15 50 10 $tag1 "$dev1" $tag2 "$dev2" $tag3 "$dev3" $tag4 "$dev4" $tag5 "$dev5" \
       $tag6 "$dev6" 2>/tmp/retdevip;;
    7) $D --title "$TITLE" --menu "$ETH" 15 50 10 $tag1 "$dev1" $tag2 "$dev2" $tag3 "$dev3" $tag4 "$dev4" $tag5 "$dev5" \
       $tag6 "$dev6" $tag7 "$dev7" 2>/tmp/retdevip;;
    8) $D --title "$TITLE" --menu "$ETH" 15 50 10 $tag1 "$dev1" $tag2 "$dev2" $tag3 "$dev3" $tag4 "$dev4" $tag5 "$dev5" \
       $tag6 "$dev6" $tag7 "$dev7" $tag8 "$dev8" 2>/tmp/retdevip;;
    9) $D --title "$TITLE" --menu "$ETH" 15 50 10 $tag1 "$dev1" $tag2 "$dev2" $tag3 "$dev3" $tag4 "$dev4" $tag5 "$dev5" \
       $tag6 "$dev6" $tag7 "$dev7" $tag8 "$dev8" $tag9 "$dev9" 2>/tmp/retdevip;;
    10)$D --title "$TITLE" --menu "$ETH" 15 50 10 $tag1 "$dev1" $tag2 "$dev2" $tag3 "$dev3" $tag4 "$dev4" $tag5 "$dev5" \
       $tag6 "$dev6" $tag7 "$dev7" $tag8 "$dev8" $tag9 "$dev9" $tag10 "$dev10" 2>/tmp/retdevip;;
    *) $D --title "$TITLE" --msgbox "$FAILIPDEV \n$IPDEVS" 15 50 2>$VARDIR/IFACEs.var
       exit 1;;
  esac 
  ret=$?
  cancel_pressed $ret

  choice=`cat /tmp/retdevip` 
  eval "DEV=\$tmp$choice"
  echo "$DEV" > $VAR_IFACE 
  sh devtrunk.sh
  exit 0
done
