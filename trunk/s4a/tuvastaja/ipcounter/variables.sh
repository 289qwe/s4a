#!/bin/sh

# /* Copyright (C) 2010, Cybernetica AS, http://www.cybernetica.eu/ */


BASEDIR=/var/www/tuvastaja/ipcounter

TMPFILE=$BASEDIR/tmp/ipaudit.out
COUNTFILE=$BASEDIR/ipcounter.txt

DAEMON=/usr/local/bin/ipaudit
DEVICE=trunk0
