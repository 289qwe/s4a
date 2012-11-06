#!/usr/local/bin/php-5.3
<?php

/*
 * Copyright (C) 2012, Cybernetica AS, http://www.cybernetica.eu/
 * */

$dbname = "/var/www/database/s4aconf.db";
$options = getopt("d:u");
if (!array_key_exists("d", $options)) {
	usage();
	exit(1);
}

$detector = $options["d"];
if (!is_string($detector)) {
	usage();
	exit(1);
}

if ((!is_file($dbname)) || (!is_readable($dbname)) || (!is_writeable($dbname))) {
	print "Error opening $dbname for reading/writing\n";
	exit(1);
}

$action = 1;

if (array_key_exists("u", $options)) {
	$action = 0;
}

$pdo = new PDO("sqlite:$dbname"); 
if (!$pdo) {
	print "Error opening database $dbname\n";
	exit(1);
}

$rowcount = 0;

$user = get_current_user();

try {
	$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
	$sql = 'UPDATE Tuvastaja SET active='.$action.', updated_by="' . $user . '" WHERE shortname=' . "\"$detector\"" . ';';
	$query = null;
	$query = $pdo->prepare($sql);
	$query->execute();
	$row = $query->fetch(PDO::FETCH_ASSOC);
}

catch (PDOException $e) {
	print "$e\n";
}
	
unset($pdo);

function usage() {
	print "Usage: activate -d <shortname> -u\n";
	print "\t<shortname> must be detectors short name\n";
	print "\t if -u switch is used then the detector will be deactivated\n";
}

?>


