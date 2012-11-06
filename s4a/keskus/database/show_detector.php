#!/usr/local/bin/php-5.3
<?php

/*
 * Copyright (C) 2012, Cybernetica AS, http://www.cybernetica.eu/
 * */

$dbname = "/var/www/database/s4aconf.db";

$options = getopt("d:");
if (!array_key_exists("d", $options)) {
	usage();
	exit(1);
}

$detector = $options["d"];
if (!is_string($detector)) {
	usage();
	exit(1);
}

if ((!is_file($dbname)) || (!is_readable($dbname))) {
	print "Error opening $dbname for reading\n";
	exit(1);
}

$pdo = new PDO("sqlite:$dbname"); 
if (!$pdo) {
	print "Error opening database $dbname\n";
	exit(1);
}

$rowcount = 0;

try {
	$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

	$sql = "SELECT t.active, t.errormask, t.shortname, t.longname, t.lastvisit, t.lastvisitMAC, t.lastvisitIP, t.lastvisitver, t.updated_by, t.sid, o.name AS tuvastaja_org FROM Tuvastaja AS t LEFT JOIN Organisation as o ON o.sid = t.tuvastaja_org WHERE t.shortname = \"$detector\";";

	$query = null;
	$query = $pdo->prepare($sql);
	$query->execute();
	$row = $query->fetch(PDO::FETCH_ASSOC);

	if ($row) {
		$sql = 'SELECT active, updated_by, activity, notAfter, notBefore, serial FROM Certificate WHERE cert_tuvastaja = ' . $row['sid'] . ';';
		$query = null;
		$query = $pdo->prepare($sql);
		$query->execute();

		$certs = $query->fetchAll(PDO::FETCH_ASSOC);

		$ret = compose_detector_row($row);
		print $ret;

		print "\n\"$detector\" certificates\n";
		$outline = compose_certificate_header();
		print $outline;
		foreach ($certs as $cert) {
			$ret = compose_certificate_row($cert);
			print $ret;
		}
	}
	else {
		print "Unknown detector";
	}
}

catch (PDOException $e) {
}
	
unset($pdo);

function compose_certificate_header()
{
	$outline = '';
	$outline .= "Serial number\t\t";
	$outline .= "Valid from\t\t";
	$outline .= "Valid to\t\t";
	$outline .= "State\n";
	return $outline;
}


function compose_certificate_row($row)
{
	$outline = '';
	$outline .= $row['serial'] . "\t";
	$outline .= date('Y-m-d H:i', $row['notBefore']) . "\t";
	$outline .= date('Y-m-d H:i', $row['notAfter']) . "\t";

	if ($row['active'] == 1) {
		$outline .= 'Active';
	}
	else {
		$outline .= 'Inactive';
	}

	$outline .= "\n";
	return $outline;
}

function compose_detector_row($row)
{
	$outline = '';

	$active = $row['active'];
	$status = intval($active);
	$snort = intval($row['errormask']) & 0x1;

	$detector = $row['shortname'];

	$outline .= "Short name: " . $detector . "\n";

	$outline .= "State: ";	
	if ($status == 1) {
		$outline .= 'OK';
	}
	else if ($status == 2) {
		$outline .= 'CERTS';
	}
	else {
		$outline .= 'OFF';
	}
	$outline .= "\n";

	$outline .= "Snort: ";	
	if ($snort <= 0) {
		$outline .= 'OK';
	}
	else {
		$outline .= 'ERROR';
	}
	$outline .= "\n";

	$outline .= "Last seen: ";
	if ($row['lastvisit'] == 0) {
		$outline .= "<unknown>";
	}
	else {
		$outline .= date('Y-m-d H:i', $row['lastvisit']);
	}
	$outline .= "\n";


	$outline .= "MAC address: ";
	if ($row['lastvisitMAC']) {
		$outline .= $row['lastvisitMAC'];
	}
	else {
		$outline .= "<unknown>";
	}
	$outline .= "\n";

	$outline .= "IP address: ";
	if ($row['lastvisitIP']) {
		$outline .= $row['lastvisitIP'];
	}
	else {
		$outline .= "<unknown>";
	}
	$outline .= "\n";

	$outline .= "Software version: ";
	if ($row['lastvisitver']) {
		$outline .= $row['lastvisitver'];
	}
	else {
		$outline .= "<unknown>";
	}
	$outline .= "\n";

	$outline .= "Organization: " . $row['tuvastaja_org'] . "\n";
	$outline .= "Description: " . $row['longname'] . "\n";

	return $outline;
}

function usage() {
	print "Usage: show_detector -d <shortname>\n";
	print "\t<shortname> must be detectors short name\n";
}


?>

