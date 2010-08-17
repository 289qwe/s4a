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
SECRETWORDSFILE=/usr/share/dict/propernames

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
    "2") if [ -s $CERTDIR/$KEYNAME ]; then
           mount_usb
           CONF=`find $MOUNTDIR -maxdepth 1 -name tuvastaja.tgz`
           if [ -n "$CONF" ]; then
             TMPCERTDIR=`mktemp -d /tmp/cacerts.XXXXXXXX`
             tar xzf $CONF -C $TMPCERTDIR
           
             # Check cert and key
             CRTMD5=`openssl x509 -noout -modulus -in $TMPCERTDIR/$DETNAME | openssl md5`
             KEYMD5=`openssl rsa -noout -modulus -in $CERTDIR/$KEYNAME | openssl md5`
             if [ $CRTMD5 = $KEYMD5 ]; then
               MAXLINES=`wc -l $SECRETWORDSFILE | sed -e 's/^ *\([0-9]*\).*/\1/g'` 
               SECRET="`sed "$(($RANDOM%$MAXLINES))q;d" $SECRETWORDSFILE` loves `sed "$(($RANDOM%$MAXLINES))q;d" $SECRETWORDSFILE`"
               SECRETFILE=`mktemp $TMPCERTDIR/XXXXXXXX`
               echo $SECRET > $SECRETFILE
               # Encrypt using public key and decrypt using private key
               openssl rsautl -encrypt -in $SECRETFILE -inkey $TMPCERTDIR/$DETNAME -certin -out "$SECRETFILE".bin
               SECRETDECRYPT=`openssl rsautl -decrypt -in "$SECRETFILE".bin -inkey $CERTDIR/$KEYNAME`
               ret=$?
               if [ $ret -ne 0 ]; then
                 # OpenSSL error
                 rm -rf $TMPCERTDIR
                 $D --title "$TITLE" --msgbox "$KEYCERTDIFF\n\n$SUGGESTNEWREQ" 15 70
                 umount_usb
                 exit 1
               fi
               if [ "$SECRET" = "$SECRETDECRYPT" ]; then
                 rm $SECRETFILE*
                 cp $TMPCERTDIR/* $CERTDIR/
                 rm -rf $TMPCERTDIR
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
                 # can't decrypt encrypted secretmessage, cert and key files doesn't match
                 rm -rf $TMPCERTDIR
                 $D --title "$TITLE" --msgbox "$KEYCERTDIFF\n\n$SUGGESTNEWREQ" 15 70
                 umount_usb
                 exit 1
               fi
             else
               # md5sum of cert and key files doesn't match
               rm -rf $TMPCERTDIR
               $D --title "$TITLE" --msgbox "$KEYCERTDIFF\n\n$SUGGESTNEWREQ" 15 70 
               umount_usb
               exit 1
             fi
           else
             # Cannot find tuvastaja.tgz
             $D --title "$TITLE" --msgbox "$KEYCERTFAIL" 15 50
             umount_usb
             exit 1
           fi
         else
           # Key-file is missing
           $D --title "$TITLE" --msgbox "$NOCERTFILE $DETECTORKEY\n\n$SUGGESTNEWREQ" 15 70 
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
