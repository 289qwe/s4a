#!/bin/sh

# Copyright (C) 2010, Cybernetica AS, http://www.cybernetica.eu/

set -e

DATABASEROOT="/var/www/database"
DATABASE="$DATABASEROOT/s4aconf.db"

UPDATESQL="$DATABASEROOT/datamodel_4.7.2-update.sql"

# Check update
if [ -f "$DATABASE" ]; then
  sqlite3 $DATABASE "Select droprate from tuvastaja;" >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    echo "Database is already up to date"
  else
    EXT=`date "+%s"`
    OLDBASE="$DATABASE.$EXT"
    echo "Updating database $DATABASE, storing backup to $OLDBASE"
    cp $DATABASE $OLDBASE
    # apply update
    sqlite3 $DATABASE < $UPDATESQL
    echo "OK"
  fi
else
  echo "Cannot find database $DATABASE, no sql-updates performed!"
  exit 1
fi



