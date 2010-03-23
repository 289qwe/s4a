<?php
/* Copyright (C) 2010, Cybernetica AS, http://www.cybernetica.eu/ */

/*
 * Functions common to statview.php and statview_rrdgraph.php
 */

function dbopen($name)
{
	$dbroot = "/tuvastaja/data/snort-reports/web";
	
	$dbdir = sprintf("%s/%s/%s", $dbroot, $GLOBALS['year_dir'], $GLOBALS['day_dir']);
	$dbfile = sprintf("%s/%s.gdbm.web", $dbdir, $name);

	if (!is_dir($dbroot)) {
		return;
	}
	if (!is_dir($dbdir)) {
		return;
	}
	if (!file_exists($dbfile)) {
		return;
	}

	$dbh = dba_open($dbfile, "rd", "gdbm");
	return $dbh;
}

function dbfetch($key, $handler)
{
	return dba_fetch($key, $handler);
}

function dbclose($handler)
{
	return dba_close($handler);
}

?>
