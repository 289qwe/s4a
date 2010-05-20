<?php
/* Copyright (C) 2010, Cybernetica AS, http://www.cybernetica.eu/ */

// No direct access
defined('SD_ADM') or die('Restricted access');

$CONFIG = array(
	'DS' => '/',		// webserver directory separator
	'system_lang_file' => 'sd_lang_et.php',
	'system_updater_log_path' => '/tuvastaja/data/updater-logs/',
	'system_updater_log_file' => 'updater.log',
	'system_snort_log_path' => '/tuvastaja/data/snort-logs/',
	'system_snort_log_file' => 'alert.fast',
	'tuvastaja_varpath' => '/tuvastaja/data/conf/',
	'system_backupfile' => 'configuration.tgz',
	'system_backupurl' => '/confbackup/',
	'system_backuppath' => '/htdocs/confbackup/',
	'system_ext_path_url' => '../ext3/',
	'system_getdata_url' => 'sd_data_engine.php',
	'system_graph_path' => '/htdocs/s4a/sd/graphs/',
	'system_graph_path_url' => '/s4a/sd/graphs/',
	'system_snortlog_archive' => '/tuvastaja/data/snort-reports',
	'system_snort_map_file' => '/tuvastaja/data/snort/sid-msg.map',
	'system_update_alert_seconds' => '86400',
	'system_update_warning_seconds' => '21600',
	'system_history_daily_url_path' => 'statview.php',
	'system_history_weekly_url_path' => '/snort-weekly',
	'system_logview_url_path' => 'logview.php',
	'grapher_rrd_tree' => '/tuvastaja/data/rrd',
	'grapher_rrd_tree_snorto' => '/tuvastaja/data/snort-reports/rrd',
	'grapher_clss_file' => 'class_rrdtool.inc',
	'user' => array(
		'authenticated' =>  false,
		'm_serial' => '',
		'fname' => '',
		'sname' => '',
		'id' => ''),
	'UI_FRAME_RELOAD_INTERVAL' => 300,    // Tab refresh interval in seconds
);

$LOGFILES = array(
	'updater' => $CONFIG['system_updater_log_path'] . $CONFIG['system_updater_log_file'],
	'alerts' => $CONFIG['system_snort_log_path'] . $CONFIG['system_snort_log_file'] 
);

$SYSCONFIG = array();


// Load more config values from system configuration
if ( file_exists($CONFIG['tuvastaja_varpath']) && is_dir($CONFIG['tuvastaja_varpath']) ) {	
	$files = scandir( $CONFIG['tuvastaja_varpath'] );
	foreach ($files as $file) {
		if (preg_match("/^(.*).var$/", $file, $match)) {
			# register CONF value using filename without file extension
			$value = '';
			$handle = @fopen($CONFIG['tuvastaja_varpath'] . $file, "r");
			if ($handle) {
				# Huvitab ainult esimene rida
				$value = iconv("ISO-8859-1", "UTF-8//TRANSLIT//IGNORE", 
						trim(fgets($handle, 4096)));
				fclose($handle);
			}
			$SYSCONFIG = array_merge( $SYSCONFIG, array($match[1] => $value) );
		}
	}
}



// grapher - endine rrdparams.inc

# yldine
$commondefs = array(
	"-c", "FONT#000000",
 	"-c", "MGRID#000000",
	"-c", "ARROW#000000",
	"-c", "FRAME#000000",
	"-c", "BACK#f5f5f5",
	"-c", "ARROW#000000", 
	"-w", "280", # width pixels
	"-h", "70", # height pixels
	"-z" 	# lazy
);


# per vahemik optsioonid
$daydefs = array (
	 "-s", "-86400", # start time
	 "-x", "HOUR:1:HOUR:6:HOUR:2:0:%H" # x-grid
);

$yeardefs = array (
	 "-s", "-31449600" # start time
	 # "-x", "HOUR:1:HOUR:6:HOUR:2:0:%H" # x-grid
);

$monthdefs = array (
	 "-s", "-2678400" # start time
	 # "-x", "HOUR:1:HOUR:6:HOUR:2:0:%H" # x-grid
);

$weekdefs = array (
	 "-s", "-604800" # start time
	 # "-x", "HOUR:1:HOUR:6:HOUR:2:0:%H" # x-grid
);

$allrangedefs = array(
	"day" => $daydefs,
	"year" => $yeardefs,
	"week" => $weekdefs,
	"month" => $monthdefs
);

# Per RRD kujundus ja andmeallikad
$cptdefs = array(
	"-v", "CPU Utilization" ,
	"-b", "1000", # base value
	"-l", "0",	# lower-limit
	"DEF:util=".$CONFIG['grapher_rrd_tree']."/XrrdnameX.cpu.rrd:ds0:AVERAGE" ,
	"VDEF:maxutil=util,MAXIMUM" ,
	"VDEF:avgutil=util,AVERAGE" ,
	"VDEF:lastutil=util,LAST" ,
	"COMMENT:              " ,
	"COMMENT:Average " ,
	"COMMENT:    Max  " ,
	"COMMENT:Current  \l" ,
	"AREA:util#00cc00:Utilization " ,
	"GPRINT:avgutil:%8.1lf" ,
	"GPRINT:maxutil:%8.1lf" ,
	"GPRINT:lastutil:%8.1lf" ,
	"COMMENT:\l" ,
	"GPRINT:lastutil:Last update\: %m-%d-%y %T %z:strftime" 
);

$seventsdefs = array(
	"-v", "Events" ,
	"-b", "1000", # base value
	"-l", "0",	# lower-limit
	"DEF:alerts=".$CONFIG['grapher_rrd_tree_snorto']."/global.rrd:alerts:AVERAGE" ,
	"DEF:signs=".$CONFIG['grapher_rrd_tree_snorto']."/global.rrd:sigs:AVERAGE" ,
	"VDEF:maxalerts=alerts,MAXIMUM" ,
	"VDEF:maxsigns=signs,MAXIMUM" ,
	"VDEF:avgalerts=alerts,AVERAGE" ,
	"VDEF:avgsigns=signs,AVERAGE" ,
	"VDEF:lastalerts=alerts,LAST" ,
	"VDEF:lastsigns=signs,LAST" ,
	"COMMENT:             " ,
	"COMMENT:Average " ,
	"COMMENT:    Max " ,
	"COMMENT:Current\l" ,
	"AREA:alerts#00cc00:Events    " ,
	"GPRINT:avgalerts:%8.0lf" ,
	"GPRINT:maxalerts:%8.0lf" ,
	"GPRINT:lastalerts:%8.0lf" ,
	"COMMENT:\l" ,
	"LINE2:signs#0000ff:Signatures" ,
	"GPRINT:avgsigns:%8.0lf" ,
	"GPRINT:maxsigns:%8.0lf" ,
	"GPRINT:lastsigns:%8.0lf",
	"COMMENT:\l" ,
	"GPRINT:lastalerts:Last update\: %m-%d-%y %T %z:strftime" 
);


$memorydefs = array(
	"-v", "Bytes" ,
	"-b", "1024", # base value
	"-l", "0",	# lower-limit
	"DEF:free=".$CONFIG['grapher_rrd_tree']."/XrrdnameX.memory.rrd:ds0:AVERAGE" ,
	"DEF:total=".$CONFIG['grapher_rrd_tree']."/XrrdnameX.memory.rrd:ds1:AVERAGE" ,
	"VDEF:maxfree=free,MINIMUM" ,
	"VDEF:avgfree=free,AVERAGE" ,
	"VDEF:lastfree=free,LAST" ,
	"VDEF:lasttotal=total,LAST" ,
	"COMMENT:         " ,
	"COMMENT:Average  " ,
	"COMMENT:    Min  " ,
	"COMMENT:Current    \l" ,
	"AREA:free#00cc00:Used " ,
	"GPRINT:avgfree:%6.1lf %sB" ,
	"GPRINT:maxfree:%6.1lf %sB" ,
	"GPRINT:lastfree:%6.1lf %sB" ,
	"COMMENT:\l" ,
	"LINE2:total#0000ff:Total" ,
	"GPRINT:lasttotal:%6.1lf %sB",
	"COMMENT:\l" ,
	"GPRINT:lasttotal:Last update\: %m-%d-%y %T %z:strftime" 
);

$diskdefs = array(
	"-v", "Percent used" ,
	"-b", "1000", # base value
	"-l", "0",	# lower-limit
	"-u", "100",
	"DEF:root=".$CONFIG['grapher_rrd_tree']."/XrrdnameX.disk.rrd:ds0:AVERAGE" ,
	"DEF:data=".$CONFIG['grapher_rrd_tree']."/XrrdnameX.disk.rrd:ds1:AVERAGE" ,
	"VDEF:maxroot=root,MAXIMUM" ,
	"VDEF:maxdata=data,MAXIMUM" ,
	"VDEF:avgroot=root,AVERAGE" ,
	"VDEF:avgdata=data,AVERAGE" ,
	"VDEF:lastroot=root,LAST" ,
	"VDEF:lastdata=data,LAST" ,
	"COMMENT:      " ,
	"COMMENT:Average" ,
	"COMMENT:   Max" ,
	"COMMENT:Current\l" ,
	"AREA:root#00cc00:/    " ,
	"GPRINT:avgroot:%6.1lf" ,
	"GPRINT:maxroot:%6.1lf" ,
	"GPRINT:lastroot:%6.1lf" ,
	"COMMENT:\l" ,
	"LINE2:data#0000ff:data " ,
	"GPRINT:avgdata:%6.1lf" ,
	"GPRINT:maxdata:%6.1lf" ,
	"GPRINT:lastdata:%6.1lf",
	"COMMENT:\l" ,
	"GPRINT:lastdata:Last update\: %m-%d-%y %T %z:strftime" 
);

$ifstatdefstmp = array(
	"-v", "Bits per second" ,
	"-b", "1000", # base value
	"-l", "0",	# lower-limit
	"6", "7",
	"CDEF:in=in0,8,*",
	"CDEF:out=out0,8,*", 
	"VDEF:maxout=out,MAXIMUM" ,
	"VDEF:maxin=in,MAXIMUM" ,
	"VDEF:avgout=out,AVERAGE" ,
	"VDEF:avgin=in,AVERAGE" ,
	"VDEF:lastout=out,LAST" ,
	"VDEF:lastin=in,LAST" ,
	"COMMENT:         " ,
	"COMMENT:Average" ,
	"COMMENT:   Max        " ,
	"COMMENT:Current  \l" ,
	"AREA:out#00cc00:In " ,
	"GPRINT:avgout:%6.1lf %sbps" ,
	"GPRINT:maxout:%6.1lf %sbps" ,
	"GPRINT:lastout:%6.1lf %sbps" ,
	"COMMENT:\l" ,
	"LINE2:in#0000ff:Out" ,
	"GPRINT:avgin:%6.1lf %sbps" ,
	"GPRINT:maxin:%6.1lf %sbps" ,
	"GPRINT:lastin:%6.1lf %sbps",
	"COMMENT:\l" ,
	"GPRINT:lastin:Last update\: %m-%d-%y %T %z:strftime" 
);

$snortodefs = array(
	"-v", "Seconds worked" ,
	"-b", "1000", # base value
	"-l", "0",	# lower-limit
	"DEF:secs=".$CONFIG['grapher_rrd_tree_snorto']."/debug.rrd:snorto:AVERAGE" ,
	"VDEF:maxsecs=secs,MAXIMUM" ,
	"VDEF:avgsecs=secs,AVERAGE" ,
	"VDEF:lastsecs=secs,LAST" ,
	"COMMENT:          " ,
	"COMMENT:Average" ,
	"COMMENT:   Max" ,
	"COMMENT:Current\l" ,
	"AREA:secs#00cc00:Duration " ,
	"GPRINT:avgsecs:%6.1lf" ,
	"GPRINT:maxsecs:%6.1lf" ,
	"GPRINT:lastsecs:%6.1lf" ,
	"COMMENT:\l" ,
	"GPRINT:lastsecs:Last update\: %m-%d-%y %T %z:strftime" 
);

$hostcdefs = array(
	"-v", "Homenet hosts" ,
	"-b", "1000", # base value
	"-l", "0",	# lower-limit
	"DEF:host=".$CONFIG['grapher_rrd_tree_snorto']."/global.rrd:activeip:AVERAGE" ,
	"DEF:badhost=".$CONFIG['grapher_rrd_tree_snorto']."/global.rrd:intip:AVERAGE" ,
	"VDEF:maxhost=host,MAXIMUM" ,
	"VDEF:maxbadhost=badhost,MAXIMUM" ,
	"VDEF:avghost=host,AVERAGE" ,
	"VDEF:avgbadhost=badhost,AVERAGE" ,
	"VDEF:lasthost=host,LAST" ,
	"VDEF:lastbadhost=badhost,LAST" ,
	"COMMENT:             " ,
	"COMMENT:Average " ,
	"COMMENT:    Max " ,
	"COMMENT:Current \l" ,
	"AREA:host#00cc00:Active IP " ,
	"GPRINT:avghost:%8.0lf" ,
	"GPRINT:maxhost:%8.0lf" ,
	"GPRINT:lasthost:%8.0lf" ,
	"COMMENT:\l" ,
	"LINE2:badhost#0000ff:Matched IP" ,
	"GPRINT:avgbadhost:%8.0lf" ,
	"GPRINT:maxbadhost:%8.0lf" ,
	"GPRINT:lastbadhost:%8.0lf",
	"COMMENT:\l" ,
	"GPRINT:lasthost:Last update\: %m-%d-%y %T %z:strftime" 
);


$if2statdefs = $ifstatdefstmp;
$if2statdefs[6] = "DEF:in0=".$CONFIG['grapher_rrd_tree']."/XrrdnameX.if2.rrd:ds1:AVERAGE";
$if2statdefs[7] = "DEF:out0=".$CONFIG['grapher_rrd_tree']."/XrrdnameX.if2.rrd:ds0:AVERAGE";

$if3statdefs = $ifstatdefstmp;
$if3statdefs[6] = "DEF:in0=".$CONFIG['grapher_rrd_tree']."/XrrdnameX.if3.rrd:ds1:AVERAGE";
$if3statdefs[7] = "DEF:out0=".$CONFIG['grapher_rrd_tree']."/XrrdnameX.if3.rrd:ds0:AVERAGE";

$if4statdefs = $ifstatdefstmp;
$if4statdefs[6] = "DEF:in0=".$CONFIG['grapher_rrd_tree']."/XrrdnameX.if4.rrd:ds1:AVERAGE";
$if4statdefs[7] = "DEF:out0=".$CONFIG['grapher_rrd_tree']."/XrrdnameX.if4.rrd:ds0:AVERAGE";

# ja votame kokku
$alltargetdefs = array(
	"hostcount" => $hostcdefs,
	"seventscount" => $seventsdefs,
	"memory" => $memorydefs,
	"if2" => $if2statdefs,
	"if3" => $if3statdefs,
	"if4" => $if4statdefs,
	"cpu" => $cptdefs,
	"disk" => $diskdefs,
	"snorto" => $snortodefs
);

?>
