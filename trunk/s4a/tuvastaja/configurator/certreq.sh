#! /bin/sh

# /* Copyright (C) 2010, Cybernetica AS, http://www.cybernetica.eu/ */


set -e

if [ "$1" = "" ]; then
  echo "First argument should be subject name!"
  exit 1
fi

if [ "$2" = "" ]; then
  echo "Second argument should be organization name!"
  exit 1
fi

SUBJ="$1"
ORG="$2"
DISNAME="/C=EE/O=$ORG/CN=$SUBJ"

TEMPDIR="/tmp"
NEWKEY="$TEMPDIR/$SUBJ.key"
NEWREQ="$TEMPDIR/$SUBJ.req"

openssl  req -sha512 -new -newkey rsa:2048 -keyout $NEWKEY -out $NEWREQ  -nodes -subj "$DISNAME"

exit 0
