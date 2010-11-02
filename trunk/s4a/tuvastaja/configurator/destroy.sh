#!/bin/sh

# /* Copyright (C) 2010, Cybernetica AS, http://www.cybernetica.eu/ */


if [ -z "$CONFROOT" ]; then
  CONFROOT=/var/www/tuvastaja/configurator
fi
if [ -z "$VARDIR" ]; then
  VARDIR=/var/www/tuvastaja/data/conf
fi

#Include functions
. $CONFROOT/functions.sh

DD="512"
DISKS=`sysctl -n hw.disknames | sed -e 's/,/ /g'`
for i in $DISKS; do
  if disklabel $i 2>/dev/null | grep -q "\/var\/www\/tuvastaja\/data"; then
    DISK=$i
  fi
done
SECTORS=`disklabel $DISK | grep "^total sectors:" | sed 's/[a-z: ]*\([0-9]*\)/\1/'`
BS=$((512 * $DD))
COUNT=$(($SECTORS / $DD))

while [ 0 ]; do
  echo "$EMPTY"
  $D --title "$TITLE" --menu "$CLEARWARN" 15 80 3 1 "$NO" 2 "$YES: $DESTROY1" 3 "$YES: $DESTROY2" 2>/tmp/retdestroy
  ret=$?
  cancel_pressed $ret

  RETDESTROY="`cat /tmp/retdestroy`"
  case "$RETDESTROY" in
    "1") rm -rf /tmp/retdestroy
         exit 0;;
    "2") $D --title "$TITLE" --infobox "$CLEARDATA" 15 80
         kill_all_and_umount_data "$DISK"

         disklabel -d -w "$DISK"d
         end_of_story;;
    "3") $D --title "$TITLE" --infobox "$CLEAR" 15 80
         kill_all_and_umount_data "$DISK"

         mount -f -r /dev/"$DISK"a
         ret=$?
         if [ $ret -ne 0 ]; then
           $D --title "$TITLE" --msgbox "$REMOUNTROOT" 15 80
           exit $ret 
         fi

         dd if=/dev/zero of=/dev/r"$DISK"c bs="$BS" count="$COUNT"
         echo "$EMPTY"
         end_of_story;;
  esac
done
