<?php
/* Copyright (C) 2010, Cybernetica AS, http://www.cybernetica.eu/ */

define ('RULE_DIR_PATH', '/confserv/signatures/');
define ('FUNCTIONS', '/confserv/common-functions.php');

include FUNCTIONS;

$sid = isset($_GET['sid']) ? $_GET['sid'] : '';
if ($_SERVER['REMOTE_USER'] == 'webroot') {
	define ('S4A_ROOT', true);
}

if ($sid == '') {
	print "No detector\n";
	exit(1);
}

$dbname = "/database/s4aconf.db";

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

?>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">

  <head>
    <title>S4A keskus: Tuvastaja</title>
    <meta http-equiv="Content-Type" content="text/html;charset=windows-1252" />
    <meta http-equiv="refresh" content="300"/>
    <link href="s4a.css" rel="stylesheet" type="text/css" /> 
  </head>

<body class="s4a-normal">
<div class="s4a">

<?php

try {
	$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

	$sql = "SELECT t.active, t.errormask, t.droprate, t.shortname, t.longname, t.lastvisit, t.lastvisitMAC, t.lastvisitIP, t.lastvisitver, t.lastvisitrulever, t.updated_by, t.sid, o.name AS tuvastaja_org FROM Tuvastaja AS t LEFT JOIN Organisation as o ON o.sid = t.tuvastaja_org WHERE t.sid = \"$sid\";";

	$query = null;
	$query = $pdo->prepare($sql);
	$query->execute();
	$row = $query->fetch(PDO::FETCH_ASSOC);
	
	$detector = $row['shortname'];

	print "<h3>Tuvastaja \"$detector\"</h3>";
	print "<a href=\"detectors.php\">&larr;</a> | <a href=\"index.html\">&uarr;</a> | <a href=\"observer.php?det=$detector\">Vaata turvarikkeid</a>";
	print "<table class=\"s4a\">";

	$outline = '';
	$outline = compose_detector_header();
	print $outline;

	$td_class = '';
	if ($td_class == "s4a-ok0") {
		$td_class = "s4a-ok1";
	}
	else {
		$td_class = "s4a-ok0";
	}

	$sql = 'SELECT active, updated_by, activity, notAfter, notBefore, serial FROM Certificate WHERE cert_tuvastaja = ' . $row['sid'] . ';';
	$query = null;
	$query = $pdo->prepare($sql);
	$query->execute();

	$certs = $query->fetchAll(PDO::FETCH_ASSOC);

	$ret = compose_detector_row($sid, $row, $td_class, '');
	print $ret[0];
	print "</table>";

	print "<h3>Tuvastaja \"$detector\" sertifikaadid</h3>";
	print "<table class=\"s4a\">";
	$outline = compose_certificate_header();
	print $outline;
	foreach ($certs as $cert) {
		$ret = compose_certificate_row($cert, $td_class);
		print $ret;
	}

	print "</table>";
}

catch (PDOException $e) {
}
	
unset($pdo);
?>

</div>
</body>
</html>

<?php

function compose_certificate_header()
{
	$outline = '';
	$outline .= '<tr>';
	$outline .= '<th>Sertifikaadi number</th>';
	$outline .= '<th>Kehtivuse algus</th>';
	$outline .= '<th>Kehtivuse l&otilde;pp</th>';
	$outline .= '<th>Olek</th>';
	$outline .= '</tr>';

	return $outline;
}


function compose_certificate_row($row, $class)
{
	$outline = '<tr>';
	$outline .= "<td class=$class>".$row['serial']."</td>";
	$outline .= "<td class=$class>".date('Y-m-d H:i', $row['notBefore'])."</td>";
	$outline .= "<td class=$class>".date('Y-m-d H:i', $row['notAfter'])."</td>";

	$outline .= "<td class=\"$class centre\">";
	if ($row['active'] == 1) {
		$outline .= '<img src="images/icon_ok.png"></img>';
	}
	else {
		$outline .= '<img src="images/icon_error.gif"></img>';
	}
	$outline .= '</td>';		

	return $outline;
}

function compose_detector_header()
{
	$outline = '';
	$outline .= '<tr>';
	$outline .= '<th>L&uuml;hinimi</th>';
	$outline .= '<th>Olek</th>';
	$outline .= '<th>Snort</th>';
	$outline .= '<th>TJPM</th>';
	$outline .= '<th>Organisatsioon</th>';
	$outline .= '<th>Kirjeldus</th>';
	$outline .= '<th>Viimati n&auml;htud</th>';
	$outline .= '<th>Kasutab reegleid</th>';
	$outline .= '<th>MAC-aadress</th>';
	$outline .= '<th>IP-aadress</th>';
	$outline .= '<th>Tarkvara ver.</th>';

	if (defined('S4A_ROOT')) {
		$outline .= '<th></th>';
	}
	$outline .= '</tr>';

	return $outline;
}


function compose_detector_row($sid, $row, $class, $url)
{
	$outline = '';
	$has_problem = 0;

	$active = $row['active'];
	$status = intval($active);

	$snort = intval($row['errormask']);
	$droprate = intval($row['droprate']);

	$outline .= '<tr>';
	$detector = $row['shortname'];

	if ($url == '') {
		$outline .= "<td class=$class>".$detector."</td>";
	}
	else {
		$outline .= "<td class=$class>"."<a href=\"detector.php?det=$detector\">".$detector."</a></td>";
	}
	
	$outline .= "<td class=\"$class centre\">";
	if ($status == 1) {
		$outline .= '<img src="images/icon_ok.png"></img>';
	}
	else if ($status == 2) {
		$outline .= '<img src="images/icon_alert.png"></img>';
		$has_problem = 1;
	}
	else {
		$outline .= '<img src="images/icon_off.gif"></img>';
		$has_problem = 1;
	}
	$outline .= '</td>';

	$outline .= "<td class=\"$class centre\">";
	if ($snort >= 95) {
		$outline .= '<img src="images/icon_ok.png"></img>';
	}
	elseif ($snort < 80) {
		$outline .= '<img src="images/icon_error.gif"></img>';
		$has_problem = 1;
	}
	else {
		$outline .= '<img src="images/icon_alert.png"></img>';
		$has_problem = 1;
	}
	
	$outline .= "<td class=\"$class centre\">";
	if ($droprate > 5) {
		$outline .= '<img src="images/icon_error.gif"></img>';
		$has_problem = 1;
	}
	else {
		$outline .= '<img src="images/icon_ok.png"></img>';
	}
	$outline .= '</td>';

	$outline .= "<td class=$class>".$row['tuvastaja_org']."</td>";
	$outline .= "<td class=$class>".$row['longname']."</td>";

	if ($row['lastvisit'] == 0) {
		$outline .= "<td class=\"s4a-problem\"></td>";
		$has_problem = 1;
	}
	else {
		if ((time() - intval($row['lastvisit'])) > 21600) {
			$outline .= "<td class=\"s4a-problem\">".date('Y-m-d H:i', $row['lastvisit'])."</td>";
			$has_problem = 1;
		}
		else {
			$outline .= "<td class=$class>".date('Y-m-d H:i', $row['lastvisit'])."</td>";
		}
	}

	if ($row['lastvisitrulever'] == 0) {
		$outline .= "<td class=\"s4a-problem\"></td>";
		$has_problem = 1;
	}
	else {
		$currentruleversion = get_current_xlevel(RULE_DIR_PATH, 'rules');
		if (intval($row['lastvisitrulever']) != $currentruleversion) {
			$outline .= "<td class=\"s4a-problem\">".date('Y-m-d H:i', $row['lastvisitrulever'])."</td>";
			$has_problem = 1;
		}
		else {
			$outline .= "<td class=$class>".date('Y-m-d H:i', $row['lastvisitrulever'])."</td>";
		}
	}

	if ($row['lastvisitMAC']) {
		$outline .= "<td class=\"$class\">".$row['lastvisitMAC']."</td>";
	}
	else {
		$outline .= "<td class=\"s4a-problem\"></td>";
		$has_problem = 1;
	}

	if ($row['lastvisitIP']) {
		$outline .= "<td class=\"$class\">".$row['lastvisitIP']."</td>";
	}
	else {
		$outline .= "<td class=\"s4a-problem\"></td>";
		$has_problem = 1;
	}

	if ($row['lastvisitver']) {
		$outline .= "<td class=\"$class\">".$row['lastvisitver']."</td>";
	}
	else {
		$outline .= "<td class=\"s4a-problem\"></td>";
	}


	if (defined('S4A_ROOT')) {
		$outline .= "<td class=\"$class centre\">";
		$outline .= "<form action=\"activate.php\" method=\"post\">";
		$outline .= "<input type=\"hidden\" name=\"action\" value=\"$active\"/>";
		$outline .= "<input type=\"hidden\" name=\"sid\" value=\"$sid\"/>";
		if ($active) {
			$outline .= "<input type=\"submit\" name=\"btn2\" value=\"Deaktiveeri\"/>";
		}
		else {
			$outline .= "<input type=\"submit\" name=\"btn2\" value=\"Aktiveeri\"/>";
		}

		$outline .= "</form>";
		$outline .= "</td>";
	}

	$outline .= '</tr>';

	return array($outline, $has_problem);
}

?>

