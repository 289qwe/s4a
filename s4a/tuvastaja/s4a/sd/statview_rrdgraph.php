<?php
/* Copyright (C) 2010, Cybernetica AS, http://www.cybernetica.eu/ */

/*
 * Skript rrd graafiku joonistamiseks etteantud signatuurile
 * päisebaasist leitavas ajavahemikus
 */

require_once 'statview_common.inc';

define ('RRDTOOL', '/bin/rrdtool');
define ('RRDPATH', '/tuvastaja/data/snort-reports/rrd');

header('Content-Type: image/png');

$rrdfilename = sprintf("%s/%s.rrd", RRDPATH, $_GET['sig']);

// Kontrollime vigu
$errmsg = "";
if (empty($_GET['sig'])) {
	$errmsg = "Argument sig määramata.";
} else
if (!is_readable($rrdfilename)) {
	$errmsg = "RRD fail ei ole leitav/loetav.";
}

// Vigade korral katkestame ja näitame võimalusel veateadet
if (!empty($errmsg)) {
//	Kuni PHP SD teeki pole, ei ole mittetoimival koodil mõtet, samas saame ka ilma hakkama
//	$img = imagecreate(300, 20);
//	imagecolorallocate($img, 255, 255, 255);
//	imagestring ($img, 1, 2, 2, "Graafiku loomine nurjus.");
//	imagestring ($img, 1, 2, 12, $errmsg, $black_color);
//	imagepng($img);
	exit;
}

// Vaikimisi näitame viimas 2 päeva andmeid
$start_time = "now - 2 days";
$end_time = "now";

// Otsime baasist, mis ajaperioodi me kuvama peaksime
//$dbh = dbopen("header");
//if ($dbh) {
//	$start_time = str_replace("-", "/", dbfetch("STARTTIME", $dbh));
//	$end_time = str_replace("-", "/", dbfetch("ENDTIME", $dbh));
//	dbclose($dbh);
//}

// Loome rrdtooli abil graafiku etteantud signatuuri kohta
$runline = sprintf("%s graph - --start \"%s\" --end \"%s\" ".
		"DEF:as=%s:alerts:AVERAGE ".
		"\"LINE1:as#FF0000:\"", RRDTOOL,
		escape_colon($start_time), 
		escape_colon($end_time),
		escape_colon($rrdfilename));
passthru($runline);

function escape_colon($input)
{
	return str_replace(':', '\\\\:', $input);
}
?>
