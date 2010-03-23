#!/bin/sh


ALLDIR="sid userdef"
DATE=`date`

SIDMAPDIR=""


for DIR in $ALLDIR
do

	RULEDIR=/var/www/tuvastaja/data/snort/$DIR
	OUTFILE=$RULEDIR/rules.conf

	if [ -d $RULEDIR ]
	then 
		cd $RULEDIR

		echo "# Generated $DATE" > $OUTFILE
		echo 

		for a in *.rules
		do
			if [ -f "$a" ]; then
				echo "include $RULEDIR/$a" >>  $OUTFILE
			fi
		done
		
		SIDMAPDIR="$SIDMAPDIR $RULEDIR"
	fi

done

/var/www/tuvastaja/snort/create-sidmap.pl  $SIDMAPDIR > /var/www/tuvastaja/data/snort/sid-msg.map

