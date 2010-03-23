<?php
/* Copyright (C) 2010, Cybernetica AS, http://www.cybernetica.eu/ */

define ('RRDTOOL', '/bin/rrdtool');
define ('RRDPATH', '/tuvastaja/data/snort-reports/rrd');

$start_time = isset($_GET['start_time']) && is_numeric($_GET['start_time']) ? $_GET['start_time'] : 0;
$end_time = isset($_GET['end_time']) && is_numeric($_GET['end_time']) ? $_GET['end_time'] : 0;
$sig_id = isset($_GET['sig_id']) ? $_GET['sig_id'] : '';

header('Content-Type: image/png');

$rrdfilename = sprintf("%s/%s.rrd", RRDPATH, $sig_id);
$errmsg = "";
if (!is_readable($rrdfilename)) {
	$errmsg = "RRD fail ei ole leitav/loetav.";
}

if (!empty($errmsg)) {
	exit;
}

if (!$start_time || !$end_time) {	
	$start_time = time() - 172800;
	$end_time = time();
}

if ($start_time > $end_time) {
	$tmp = $start_time;
	$start_time = $end;
	$end = $tmp;
}

// Loome rrdtooli abil graafiku etteantud signatuuri kohta
$runline = sprintf("%s graph - --start %d --end %d --slope-mode ".
		"--height 300 ".
		"--width 600 ".
		"DEF:as=%s:alerts:AVERAGE ".
		"\"AREA:as#00FF00:alerte\"", RRDTOOL,
		$start_time, 
		$end_time,
		escape_colon($rrdfilename));


passthru($runline);

function escape_colon($input)
{
	return str_replace(':', '\\\\:', $input);
}


?>

