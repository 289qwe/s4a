#!/usr/local/bin/php-5.3
<?php

/*
 * Copyright (C) 2012, Cybernetica AS, http://www.cybernetica.eu/
 * */

$dbname = "/var/www/database/s4aconf.db";
$certfile = "tuvastaja.crt";

$options = getopt("bf:");
if (!array_key_exists("f", $options)) {
	usage();
	exit(1);
}

$tarball = $options["f"];
if (!is_string($tarball)) {
	usage();
	exit(1);
}

if ((!is_file($tarball)) || (!is_readable($tarball))) {
	usage();
	exit(1);
}

$untar = sprintf("tar -zxvf %s %s", $tarball, $certfile);

$retval = execute($untar, $response);
if ($retval) {
	print "\nToo many errors untarring archive, cannot continue\n";
	usage();
	exit(1);
}

if ((!is_file($certfile)) || (!is_readable($certfile))) {
	usage();
	clean($certfile);
	exit(1);
}

if ((!is_file($dbname)) || (!is_readable($dbname)) || (!is_writeable($dbname))) {
	print "Error opening $dbname for reading/writing\n";
	clean($certfile);
	exit(1);
}

$dbcopy = "$dbname." . date("YmdHi");
if (!copy($dbname, $dbcopy)) {
	print "Error making backup copy of the database\n";
	clean($certfile);
	exit(1);
}

print "Copy of the original database is stored in $dbcopy\n";
print "In case of errors you can restore the original state from there\n";

$cmd = sprintf("openssl x509 -in %s  -subject -nameopt multiline -dates -serial -noout", $certfile);

$retval = execute($cmd, $response);
if ($retval) {
	print "\nToo many errors, cannot continue\n";
	clean($certfile);
	exit(1);
}

if (count($response) != 9) {
	usage();
	clean($certfile);
	exit(1);
}
	
$tmp = explode('=', $response[3]);
$orgName = ltrim($tmp[1]);
$tmp = explode('=', $response[4]);
$fullName = ltrim($tmp[1]);
$tmp = explode('=', $response[5]);
$shortName = ltrim($tmp[1]);
$tmp = explode('=', $response[6]);
$notBef = strtotime($tmp[1]);
$tmp = explode('=', $response[7]);
$notAft = strtotime($tmp[1]);
$tmp = explode('=', $response[8]);
$serial = $tmp[1];

if (empty($orgName) || empty($fullName) || empty($shortName) || 
	empty($notBef) || empty($notAft) || empty($serial)) {
	usage();
	clean($certfile);
	exit(1);
}

$user = get_current_user();

print "$user is adding detector certificate\n";
print "Organization: $orgName\n";
print "Detector: $shortName ($fullName)\n";
print "Certificate: $serial\n";

$continue = "false";
if (!array_key_exists("b", $options)) {
	print "Proceed to continue? (y/n): ";
	$userinput = rtrim(fgets( STDIN ));
	if ($userinput == "y") {
		$continue = "true";
	} 
}
else {
	$continue = "true";
}

if ($continue == "false") {
	print "Cancelled by the $user\n";
	clean($certfile);
	exit(1);
}


$pdo = new PDO("sqlite:$dbname"); 
if (!$pdo) {
	print "Error opening database $dbname\n";
	clean($certfile);
	exit(1);
}

try {
	$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
	if (!certificateExists($pdo, $serial)) {
		$oid = updateOrg($pdo, $orgName);
		if ($oid) {
			$sid = updateDetector($pdo, $fullName, $shortName, $oid, $user);
			if ($sid) {
				updateDetectorCertificates($pdo, $notBef, $notAft, $serial, $sid, $user);
			}
			else {
				print "Error updating detectors\n";
			}
		}
		else {
			print "Error updating organizations\n";
		}
	} 
	else {
		print "Certificate with serial $serial already exists. Nothing updated.\n";
	}
}
catch (PDOException $e) {

}
	
unset($pdo);
clean($certfile);

function usage() {
	print "Usage: update_db [-b] -f <certarchive>\n";
	print "\t<certarchive> must be tar.gz-formatted archive\n";
	print "\t<certarchive> must contain file named 'tuvastaja.crt' which is X509 certificate\n";
	print "\tFollowing distinguished name components must be set:\n";
	print "\t\tcountryName\n";
	print "\t\tlocalityName\n";
	print "\t\torganizationName\n";
	print "\t\torganizationalUnitName\n";
	print "\t\tcommonName\n";
	print "If '-b' option is set, then certificate will be added without asking confirmation\n";
	print "Example: update_db -b -f <certarchive>\n";
}

function clean($file) {
	system("rm -f $file");
}

function updateDetectorCertificates($pdo, $notBef, $notAft, $serial, $det_sid, $user) {

	$sql = 'UPDATE Certificate SET active = 0, activity = ' . time() . ', updated_by = "' . $user . '" WHERE cert_tuvastaja = ' . $det_sid . ';';

	$query = null;
	$query = $pdo->prepare($sql);
	$query->execute();

	$sql = sprintf("INSERT INTO Certificate ( active, cert_tuvastaja, notBefore, notAfter, serial, updated_by, activity ) VALUES ( %d, %d, %d, %d, '%s', '%s', %d );", 
		 1, 
		 $det_sid, 
		 $notBef, 
		 $notAft, 
		 $serial,
		 $user,
		 time()
	);
				
	$query = null;
	$query = $pdo->prepare($sql);
	$query->execute();
				
	$cid = intval($pdo->lastInsertId());				
}

function findDetector($pdo, $id) {
	$sql = sprintf("SELECT sid FROM Tuvastaja WHERE shortname=\"%s\";", $id);
	$query = null;
	$query = $pdo->prepare($sql);
	$query->execute();
	$row = $query->fetch(PDO::FETCH_ASSOC);
	$rowcount = count($row);
	$sid = 0;
	if ($rowcount > 1) {
		print "Invalid data in table Tuvastaja\n";
		return -1;
	}
			
	if ($rowcount && intval($row['sid']) > 0 ) {
		$sid = intval($row['sid']);
	}

	return $sid;	
}

function updateDetector($pdo, $name, $id, $oid, $user) {
	$sid = findDetector($pdo, $id);
	if ($sid < 0) {
		return 0;
	}

	if ($sid) {
		$sql = sprintf("UPDATE Tuvastaja SET longname=\"%s\", tuvastaja_org=%d, updated_by=\"%s\" WHERE sid=%d;",
			$name,
			$oid,
			$user,
			intval($sid));
	
		$query = null;
		$query = $pdo->prepare($sql);
		$query->execute();
	}
	else {
		$sql = "INSERT INTO Tuvastaja ( active, longname, shortname, tuvastaja_org, updated_by ) VALUES ( 1, '" . 
				$name . "', '" . $id . "', $oid, '" . $user . "' );";
			
		$query = null;
		$query = $pdo->prepare($sql);
		$query->execute();
		$sid = intval($pdo->lastInsertId());
	}

	return $sid;
}

function certificateExists($pdo, $serial) {
	$sql = 'SELECT serial FROM Certificate WHERE serial="' . $serial . '";';
	$query = null;
	$query = $pdo->prepare($sql);
	$query->execute();
	$rows = $query->fetchAll(PDO::FETCH_ASSOC);
	$rowcount = count($rows);
	return ($rowcount > 0);	
}

function updateOrg($pdo, $name) {

	$oid = 0;
	$sql = 'SELECT sid FROM Organisation WHERE name="' . $name . '";';
			
	$query = null;
	$query = $pdo->prepare($sql);
 	$query->execute();
	 						
 	$row = $query->fetch(PDO::FETCH_ASSOC);
 	$rowcount = count($row);

	if ($rowcount > 1) {
		print "Invalid data in table Organisation\n";
		return 0;
	}
 						
	if ($rowcount && intval($row['sid']) > 0 ) {
		$oid = intval($row['sid']);
	}
	else {
		print "Adding new organization \"$name\"\n";
		$sql = 'INSERT INTO Organisation ( name ) VALUES ( "' . $name . '" );';
		$query = null;
		$query = $pdo->prepare($sql);
		$query->execute();
		$oid = $pdo->lastInsertId();		
	}
	return $oid;
}


function execute($command, &$ret)
{
	$ret = array();
	$retval = 0;

	exec(sprintf("%s 2>&1", $command), $ret, $retval);
	if ($retval == 0) {
		return 0;
	}
	print "Executed: $command (ended abnormally retval=$retval)";
	foreach ($ret as $nr => $retline) {
		print "Line $nr: $retline";
	}
	return $retval;
}

?>

