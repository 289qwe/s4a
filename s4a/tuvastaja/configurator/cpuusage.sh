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

# File for holding cp_time past values
TMPCPU=/tmp/kern.cp_time

# First period is 5 secs
if [ ! -s $TMPCPU ]; then
  STARTCMD=`sysctl -n kern.cp_time | sed -e 's/,/ /g'`
  sleep 5
else
  STARTCMD=`cat $TMPCPU`
fi

ENDCMD=`sysctl -n kern.cp_time | sed -e 's/,/ /g'`
echo $ENDCMD > $TMPCPU

# CPU times at start of the experiment
STARTUSER=`echo $STARTCMD | awk '{print $1}'`
STARTNICE=`echo $STARTCMD | awk '{print $2}'`
STARTSYSTEM=`echo $STARTCMD | awk '{print $3}'`
STARTINTERRUPT=`echo $STARTCMD | awk '{print $4}'`
STARTIDLE=`echo $STARTCMD | awk '{print $5}'`

# CPU times at the end of the experiment
ENDUSER=`echo $ENDCMD | awk '{print $1}'`
ENDNICE=`echo $ENDCMD | awk '{print $2}'`
ENDSYSTEM=`echo $ENDCMD | awk '{print $3}'`
ENDINTERRUPT=`echo $ENDCMD | awk '{print $4}'`
ENDIDLE=`echo $ENDCMD | awk '{print $5}'`

USED=$(($ENDUSER + $ENDNICE + $ENDSYSTEM + $ENDINTERRUPT - $STARTUSER - $STARTNICE - $STARTSYSTEM - $STARTINTERRUPT))
TOTAL=$(($USED + $ENDIDLE - $STARTIDLE))

PERCENT=`echo $(($USED * 100000 / $TOTAL)) | sed -e 's/\([0-9]\{3\}\)$/\.\1/'`

# For MRTG
echo $PERCENT
echo $PERCENT
echo 0
echo cpuUsageInLastFiveMinutes
