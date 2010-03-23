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
IPDEVS=`ifconfig -a | grep 'BROADCAST' | grep -v  'trunk'  | sed 's/^\(.*\)\: .*/\1/'`
MAINIFACE=`cat $VARDIR/$IFACE`

TRUNKDEVS=`echo $IPDEVS | sed "s/^\(.*\)$MAINIFACE\(.*\)/\1\2/"`

count=1
for DEV in $TRUNKDEVS; do
  eval "dev$count=\"$DEV\""
  eval "tag$count=\"$count\"" 
  count=$(($count + 1))
done
count=$(($count - 1))

while true; do
  case $count in
    1) $D --title "$TITLE" --checklist "$TRUNK" 15 50 9 $tag1 "$dev1" on 2>/tmp/retdevtrunk;;
    2) $D --title "$TITLE" --checklist "$TRUNK" 15 50 9 $tag1 "$dev1" on $tag2 "$dev2" on 2>/tmp/retdevtrunk;;
    3) $D --title "$TITLE" --checklist "$TRUNK" 15 50 9 $tag1 "$dev1" on $tag2 "$dev2" on $tag3 "$dev3" on 2>/tmp/retdevtrunk;;
    4) $D --title "$TITLE" --checklist "$TRUNK" 15 50 9 $tag1 "$dev1" on $tag2 "$dev2" on $tag3 "$dev3" on $tag4 "$dev4" on 2>/tmp/retdevtrunk;;
    5) $D --title "$TITLE" --checklist "$TRUNK" 15 50 9 $tag1 "$dev1" on $tag2 "$dev2" on $tag3 "$dev3" on $tag4 "$dev4" on $tag5 "$dev5" on \
       2>/tmp/retdevtrunk;;
    6) $D --title "$TITLE" --checklist "$TRUNK" 15 50 9 $tag1 "$dev1" on $tag2 "$dev2" on $tag3 "$dev3" on $tag4 "$dev4" on $tag5 "$dev5" on \
       $tag6 "$dev6" on 2>/tmp/retdevtrunk;;
    7) $D --title "$TITLE" --checklist "$TRUNK" 15 50 9 $tag1 "$dev1" on $tag2 "$dev2" on $tag3 "$dev3" on $tag4 "$dev4" on $tag5 "$dev5" on \
       $tag6 "$dev6" on $tag7 "$dev7" on 2>/tmp/retdevtrunk;;
    8) $D --title "$TITLE" --checklist "$TRUNK" 15 50 9 $tag1 "$dev1" on $tag2 "$dev2" on $tag3 "$dev3" on $tag4 "$dev4" on $tag5 "$dev5" on \
       $tag6 "$dev6" on $tag7 "$dev7" on $tag8 "$dev8" on 2>/tmp/retdevtrunk;;
    9) $D --title "$TITLE" --checklist "$TRUNK" 15 50 9 $tag1 "$dev1" on $tag2 "$dev2" on $tag3 "$dev3" on $tag4 "$dev4" on $tag5 "$dev5" on \
       $tag6 "$dev6" on $tag7 "$dev7" on $tag8 "$dev8" on $tag9 "$dev9" on 2>/tmp/retdevtrunk;;
    *) if [ -z $TRUNKDEVS ]; then $D --title "$TITLE" --msgbox "$FAILTRUNKDEV" 15 50
         echo "lo0" > $VARDIR/$TRUNKIFACES
         else echo "Viga snorti liideste leidmisel"
       fi
       exit 1;;
  esac 
  ret=$?
  cancel_pressed $ret

  rettrunk=`cat /tmp/retdevtrunk`
  # Remove quotes
  choices=""
  sep=""
  for i in $rettrunk; do
    j=`echo $i | sed 's/"\([0-9]\)"/\1/'`
    choices=$choices$sep$j
  sep=" "
  done

  for a in $choices; do 
    eval "DEV=\$dev$a"
    echo "$DEV" >> /tmp/$TRUNKIFACES
  done

  # Make file with one line
  LINE=""
  SEPAR=""
  for i in `cat /tmp/$TRUNKIFACES`; do
    LINE=$LINE$SEPAR$i
    SEPAR=" "
  done
  echo "$LINE" > $VARDIR/$TRUNKIFACES
  rm -rf /tmp/$TRUNKIFACES

  exit 0
done
