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

# Some neccessary variables
HOST=`cat $VAR_HOSTNAME`
DOM=`cat $VAR_DOMAIN`

if [ "$1" = "secondary" ]; then
  CERTDIR=/var/www/tuvastaja/data/cacerts2
  MENUITEM=$ITEM5
else
  CERTDIR=/var/www/tuvastaja/data/cacerts
  MENUITEM=$ITEM4
fi

TARNAME=`echo $CERTDIR | sed 's/^.*\/\([a-z0-9]*\)/\1/'`.tgz

kmenu=1
while [ 0 ]; do
  $D --title "$TITLE" --default-item "$kmenu" --menu "$MENUITEM" 15 80 5 1 "$KEY1" \
  2 "$KEY2" 3 "$KEYBACKUP" 4 "$KEYRESTORE" 5 "$IP10" 2>/tmp/retkey
  ret=$?
  cancel_pressed $ret

  RETKEY="`cat /tmp/retkey`"
  kmenu=$RETKEY
  case "$RETKEY" in
    "1") if [ -s $VAR_HOSTNAME ]; then
           if [ -s $VAR_DOMAIN ]; then
             mount_usb
             ask_value "$KEY1ASK" "$LOCALORG" "^.*$" "$FAILTEXT"
             ./certreq.sh "$HOST.$DOM" "`cat $VAR_LOCALORG`"
             cp /tmp/"$HOST.$DOM".req "$MOUNTDIR"/
             cp /tmp/"$HOST.$DOM".key "$CERTDIR"/$KEYNAME
             rm -f $VAR_LOCALORG /tmp/"$HOST.$DOM".*
             umount_usb
             $D --title "$TITLE" --msgbox "$REQSUCC" 15 50
             exit 0
           else
             $D --title "$TITLE" --msgbox "$NOHOSTDOM" 15 50
             exit 1
           fi
         else
           $D --title "$TITLE" --msgbox "$NOHOSTDOM" 15 50
           exit 1
         fi;;
    "2") mount_usb
         CONF=`find $MOUNTDIR -maxdepth 1 -name tuvastaja.tgz`
         
         if [ -n "$CONF" ]; then
           tar xzf $CONF -C $CERTDIR
           if [ "$1" != "secondary" ]; then
             if [ -s $CERTDIR/$PATCHNAME ]; then
               cat $CERTDIR/$PATCHNAME >> /etc/ssl/pkgca.pem
               cat $CERTDIR/$CANAME >> /etc/ssl/pkgca.pem
               NOCERT=""
             else
               NOCERT="$NOPATCHCERT"
             fi
           else
             NOCERT=""
           fi
           perl $CONFROOT/getcertdata "$1"
         
           # Make modification to nrpe.local.cfg with Centralserver
           cd $CONFROOT
           make_conf nrpe
           $D --title "$TITLE" --msgbox "$KEYSUCC\n\n$NOCERT" 15 50
           umount_usb
           exit 0
         else
           $D --title "$TITLE" --msgbox "$KEYCERTFAIL" 15 50
           umount_usb
           exit 1
         fi;;
    "3") mount_usb
         cd $CERTDIR
         ret=0
         error=$CERTBACKUPFAIL
         verify_var "$CERTDIR/$CANAME";
         if [ $? -ne 0 ]; then
           error="$error\n$NOCERTFILE $CACERT"
           ret=1
         fi
         verify_var "$CERTDIR/$DETNAME";
         if [ $? -ne 0 ]; then
           error="$error\n$NOCERTFILE $DETECTORCERT"
           ret=1
         fi
         verify_var "$CERTDIR/$KEYNAME";
         if [ $? -ne 0 ]; then
           error="$error\n$NOCERTFILE $DETECTORKEY"
           ret=1
         fi

         if [ $ret -ne 0 ]; then
           $D --title "$TITLE" --msgbox "$error" 15 80
           unset error
           umount_usb
           exit 1
         else
           tar czf /tmp/$TARNAME *
           crypt e /tmp/$TARNAME $MOUNTDIR/$TARNAME.enc
           if [ $? -ne 0 ]; then
             $D --title "$TITLE" --msgbox "$CERTBACKUPFAIL\n\n$PASSDIFF" 15 50
             rm /tmp/$TARNAME
             umount_usb
           else
             $D --title "$TITLE" --msgbox "$CERTBACKUPSUCC" 15 50
             rm /tmp/$TARNAME
             umount_usb
             exit 0
           fi
         fi;;
    "4") if [ "$1" != "secondary" ]; then
           sh certrestore.sh "$TARNAME" "$CERTDIR"
         else
           sh certrestore.sh "$TARNAME" "$CERTDIR" "secondary"
         fi;;
    "5") rm -f /tmp/retkey
         exit 0
  esac
done
