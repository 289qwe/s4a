#!/bin/sh

# /* Copyright (C) 2011, Cybernetica AS, http://www.cybernetica.eu/ */


# Include variables
. $CONFROOT/variables.sh
# Include defined values
. $CONFROOT/values.sh
# This file consists of necessary functions

D=/usr/local/bin/dialog
export D

# Directory for mounting usb
MOUNTDIR=/mnt/flashdrive
WEBDIR=/var/www/htdocs/confbackup


# Ask until correct
ask=1

# regexp's
IPEXP="^[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}$"
HOSTEXP="^[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9]$"
DOMAINEXP="^[a-zA-Z0-9\.-]*$"
EMAILEXP="^.*@.*$"
ANYEXP="^[a-zA-Z0-9_\.-]*$"
CIDREXP="^[0-9]\{1,3\}\(\.[0-9]\{1,3\}\)\{3\}/[0-9]\{1,2\}\( [0-9]\{1,3\}\(\.[0-9]\{1,3\}\)\{3\}/[0-9]\{1,2\}\)\{0,\} *$"

# Function for checking validity
is_valid () 
{
  DEFFILE="$1"
  REGEXP="$2"
  FAILMSG="$3"
  if grep -q -R "$REGEXP" /tmp/$DEFFILE; then
    cp /tmp/$DEFFILE $VARDIR/ 
    ask=0
  else
    $D --title "$TITLE" --msgbox "$FAILMSG" 15 50
    ask=1 
  fi
  rm -rf /tmp/$DEFFILE
}

# Function for asking values until correct
ask_value ()
{
  MENU="$1"
  DEFFILE="$2"
  REGEXP="$3"
  FAILMSG="$4"
  while [ $ask -ne 0 ] ; do
    if [ -s $VARDIR/$DEFFILE ]; then
      $D --title "$TITLE" --inputbox "$MENU" 15 60 "`cat $VARDIR/$DEFFILE`" 2>/tmp/$DEFFILE
    else
      $D --title "$TITLE" --inputbox "$MENU" 15 60 2>/tmp/$DEFFILE
    fi
    if [ $? -eq 0 ]; then
      is_valid "$DEFFILE" "$REGEXP" "$FAILMSG"
    else 
      return 1
    fi
  done
  ask=1
  rm -rf /tmp/$DEFFILE
}

# When user press cancel, then exit corresponding script
cancel_pressed ()
{
  if [ $1 -eq 127 ]; then
    echo "Unable to exec dialog! Press enter."
    read junk
    exit $1
  elif [ $1 -eq 1 ]; then
    clear
    exit $1
  fi
}

# Make target and print it out
make_conf ()
{
  TMPFILE=/tmp/make.out
  TMPERR=/tmp/makeerr.out
  TARGET="$1"
    cd $CONFROOT
    $D --title "$TITLE" --infobox "$WAIT" 20 70
    make $TARGET >$TMPFILE 2>$TMPERR
    cat $TMPERR >>$TMPFILE
    echo "" >>$TMPFILE
    echo "Make executed. Finished." >>$TMPFILE 
    $D --title "$TITLE" --textbox "$TMPFILE" 20 70
  rm -rf "$TMPFILE"
  rm -rf "$TMPERR"
}

# Create directory if doesn't exist
make_dir ()
{
  DIRPATH=$1
  if [ ! -d $DIRPATH ]; then
    mkdir -p $DIRPATH
  fi
}

# Create account for daemon user
create_daemon_user ()
{
  USER=$1
  ID=$2
  if ! grep -q -R "^$USER:" /etc/group; then
    groupadd -g $ID $USER
  fi
  if ! grep -q -R "^$USER:" /etc/passwd; then
    user add -g $USER -u $ID -L daemon -s /sbin/nologin -d /nonexistent -c "Daemon Account" $USER
  fi
}

# Create account for regular user
create_user ()
{
  USER=$1
  if ! grep -q -R "^$USER:" /etc/group; then
    groupadd $USER
  fi
  if ! grep -q -R "^$USER:" /etc/passwd; then
    useradd -m -g $USER -b /home -c "$USER Account" $USER
  fi
}

# Kill process if running
if_running ()
{
  PROC=$1
  if pgrep "$PROC" > /dev/null; then
    pkill $PROC
    sleep 2
  fi
}

# Verify if required variable exists
verify_var ()
{
  VAR="$1"
  if [ -s $VAR ]; then
    a=`cat $VAR`
    if [ -n "$a" ]; then
      return 0
    else
      return 1
    fi
  else
    return 1
  fi
}

# Check whether it's clean install or reinstall
check_first_install ()
{
  if [ -s $VAR_SOFTWARE_VERSION ]; then
    return 0;
  fi
  return 1;
}

# Kill detector processes and umount partition that stores data
kill_all_and_umount_data () 
{
  HD="$1"
  cd $CONFROOT
  apachectl stop >/dev/null 2>&1
  pkill nrpe
  pkill syslogd
  pkill pflogd
  pkill mrtg
  pkill ntpd
  pkill snort
  pkill -9 ipaudit
  pkill cron
  pkill sendmail
  pkill inetd
  sleep 10

  umount /dev/"$HD"d 
  ret=$?
  if [ $ret -ne 0 ]; then 
    $D --title "$TITLE" --msgbox "$UMOUNTDATA" 15 80
    exit $ret
  fi
}

# Run endless loop
end_of_story ()
{
  while [ 0 ]; do
    trap "" 2
    read nothing
  done
}

# Check if all required variables are set for intrusion
# detector and make backup.
# Whether variable "usb" or "exit" the backup will be
# stored on usb or local disk.
check_end ()
{
  KEY="$1"
  ret=0
  retwarn=0
  error=$BACKUPFAIL
  errorwarn=$BACKUPWARNFAIL
  verify_var "$VAR_NTP_SERVER"
  if [ $? -ne 0 ]; then
    error="$error\n$VARNOTSET $NTP"
    ret=1
  fi
  verify_var "$VAR_LOCALNETS";
  if [ $? -ne 0 ]; then
    error="$error\n$VARNOTSET $SNORT"
    ret=1
  fi
  verify_var "$VAR_SYSLOGSERVER";
  if [ $? -ne 0 ]; then
    error="$error\n$VARNOTSET $SYSLOG"
    ret=1
  fi
  verify_var "$VAR_SMTP";
  if [ $? -ne 0 ]; then
    error="$error\n$VARNOTSET $EMAIL2"
    ret=1
  fi
  verify_var "$VAR_IFACE"
  if [ $? -ne 0 ]; then
    error="$error\n$VARNOTSET $ETH"
    ret=1
  fi
  verify_var "$VAR_TRUNKIFACES"
  if [ $? -ne 0 ]; then
    error="$error\n$VARNOTSET $TRUNK"
    ret=1
  fi
  verify_var "$VAR_IP_ADDRESS"
  if [ $? -ne 0 ]; then
    error="$error\n$VARNOTSET $IP2"
    ret=1
  fi
  verify_var "$VAR_SUBNET_MASK"
  if [ $? -ne 0 ]; then
    error="$error\n$VARNOTSET $IP3"
    ret=1
  fi
  verify_var "$VAR_DEFAULT_GATEWAY"
  if [ $? -ne 0 ]; then
    error="$error\n$VARNOTSET $IP4"
    ret=1
  fi
  verify_var "$VAR_HOSTNAME"
  if [ $? -ne 0 ]; then
    error="$error\n$VARNOTSET $IP5"
    ret=1
  fi
  verify_var "$VAR_DOMAIN"
  if [ $? -ne 0 ]; then
    error="$error\n$VARNOTSET $IP6"
    ret=1
  fi
  verify_var "$VAR_NAMESERVERS"
  if [ $? -ne 0 ]; then
    error="$error\n$VARNOTSET $IP7"
    ret=1
  fi
  verify_var "$VAR_SNMP_SERVER";
  if [ $? -ne 0 ]; then
    error="$error\n$VARNOTSET $SNMP"
    ret=1
  fi
  #verify_var "$VAR_RO_COMMUNITY"
  #if [ $? -ne 0 ]; then
    #error="$error\n$VARNOTSET $SNMPCOMMUNITY"
    #ret=1
  #fi
  verify_var "$VAR_SHORTNAME"
  if [ $? -ne 0 ]; then
    errorwarn="$errorwarn\n$VARNOTSET $CERT1"
    retwarn=1
  fi
  verify_var "$VAR_FULLNAME"
  if [ $? -ne 0 ]; then
    errorwarn="$errorwarn\n$VARNOTSET $CERT2"
    retwarn=1
  fi
  verify_var "$VAR_ORGANISATION"
  if [ $? -ne 0 ]; then
    errorwarn="$errorwarn\n$VARNOTSET $CERT3"
    retwarn=1
  fi
  verify_var "$VAR_CENTRALSERVER"
  if [ $? -ne 0 ]; then
    errorwarn="$errorwarn\n$VARNOTSET $CERT4"
    retwarn=1
  fi

  if [ $ret -ne 0 ]; then
    $D --title "$TITLE" --msgbox "$error" 30 100
    unset error
    if [ "$KEY" = "usb" ]; then
      return 1 
    elif [ "$KEY" = "exit" ]; then
      clear
      exit 1
      rm /tmp/ret*
    else 
      return 1
    fi
  fi

  tar czPf $WEBDIR/configuration.tgz $VARIABLES
  if [ $retwarn -ne 0 ]; then
    if [ "$KEY" = "usb" ]; then
      cp $WEBDIR/configuration.tgz $MOUNTDIR
      $D --title "$TITLE" --msgbox "$BACKUPSUCC\n$errorwarn" 30 100
    elif [ "$KEY" = "exit" ]; then
      $D --title "$TITLE" --msgbox "$errorwarn" 30 100
      clear
      exit 0
      rm /tmp/ret*
    else
      return 2
    fi
  else
    make_conf version
    if [ "$KEY" = "usb" ]; then
      cp $WEBDIR/configuration.tgz $MOUNTDIR
      $D --title "$TITLE" --msgbox "$BACKUPSUCC" 15 50
    elif [ "$KEY" = "exit" ]; then
      clear
      exit 0
      rm /tmp/ret*
    else
      return 0
    fi
  fi
}

# Function for mounting usb-device
mount_usb ()
{
  make_dir $MOUNTDIR
  ALLDEVS=`sysctl -n hw.disknames | sed -e 's/:[0-9a-z]\{0,\},\{0,1\}/ /g'`
  DEVS="$ALLDEVS"
  for i in $ALLDEVS; do
    if echo $i | grep -q "^cd" || echo $i | grep -q "^fd"; then
    DEVS=`echo $DEVS | sed "s/\(.*\)$i\(.*\)/\1\2/"`
    fi
  done

  for i in $DEVS; do
    mount /dev/"$i"i $MOUNTDIR 2>/dev/null
    if [ $? -ne 0 ]; then
      fail=1
    else
      fail=0
      return 0
    fi
  done
  if [ $fail -ne 0 ]; then
    $D --title "$TITLE" --msgbox "$MOUNTFAIL" 15 50
    exit 1
  fi
}

# Function for unmounting usb-device
umount_usb ()
{
  umount $MOUNTDIR
  ret=$?
  if [ $ret -ne 0 ]; then
    $D --title "$TITLE" --msgbox "$UMOUNTFAIL" 15 50
    exit 1
  fi
}

# Function for crypting/decrypting
crypt ()
{
  OPTION="$1"
  INPUT="$2"
  OUTPUT="$3"
  case $OPTION in
    "e") openssl enc -aes-256-cbc -a -in $INPUT -out $OUTPUT
         if [ $? -ne 0 ]; then
           return 1
         else
           return 0
         fi;;
    "d") openssl enc -d -aes-256-cbc -a -in $INPUT -out $OUTPUT
         if [ $? -ne 0 ]; then
           return 1
         else
           return 0
         fi;;
    "*") echo "expecting options e or d"
         return 1;;
  esac
}

# Function for network counters
traffic ()
{
  INTERFACE="$1"
  NETSTATCMD=`netstat -ibn | grep $INTERFACE | grep Link`
  echo $NETSTATCMD | awk '{printf("%s\n",$5);}'
  echo $NETSTATCMD | awk '{printf("%s\n",$6);}'
  echo 0
  echo Interface $INTERFACE
}
