#!/bin/sh

# Copyright (C) 2010, Cybernetica AS, http://www.cybernetica.eu/

set -e

DATABASEROOT="/var/www/database"
DATABASE="$DATABASEROOT/s4aconf.db"

UPDATESQL="$DATABASEROOT/datamodel_4.7.2-update.sql"

if [ -f "$DATABASE" ]; then
  EXT=`date "+%s"`
  OLDBASE="$DATABASE.$EXT"
  echo "Updating database $DATABASE, storing backup to $OLDBASE"
  cp $DATABASE $OLDBASE
else
  echo "Cannot find database $DATABASE, no sql-updates performed!"
  exit 1
fi

# apply update
sqlite3 $DATABASE < $UPDATESQL
echo "OK"
exit 0
