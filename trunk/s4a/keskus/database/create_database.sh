#!/bin/sh

# Copyright (C) 2010, Cybernetica AS, http://www.cybernetica.eu/


set -e


DATABASEROOT="/var/www/database"

DATABASE="$DATABASEROOT/s4aconf.db"

MODELDEF="$DATABASEROOT/datamodel.sql"
TRIGGERDEF="$DATABASEROOT/triggerts.sql"

if [ -f "$DATABASE" ]
then
	EXT=`date "+%s"`
	OLDBASE="$DATABASE.$EXT"
	mv $DATABASE $OLDBASE
	echo "Database $DATABASE already exists, renamed to $OLDBASE"
fi

# teeem baasi
sqlite3 $DATABASE <  $MODELDEF
sqlite3 $DATABASE <  $TRIGGERDEF

chgrp www $DATABASE
chmod g+w $DATABASE

chgrp www $DATABASEROOT
chmod g+w $DATABASEROOT

echo "OK"
exit 0

