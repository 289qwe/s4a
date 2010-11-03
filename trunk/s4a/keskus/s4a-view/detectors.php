<?php

/* Copyright (C) 2010, Cybernetica AS, http://www.cybernetica.eu/ */

define ('RULE_DIR_PATH', '/confserv/signatures/');
define ('FUNCTIONS', '/confserv/common-functions.php');

include FUNCTIONS;

if ($_SERVER['REMOTE_USER'] == 'webroot') {
	define ('S4A_ROOT', true);
}

$prob = isset($_GET['prob']) && is_numeric($_GET['prob']) ? $_GET['prob'] : 0;
$value_prob = 1;


$active = isset($_GET['active']) && is_numeric($_GET['active']) ? $_GET['active'] : 0;
$value_active = 1;


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
    <title>S4A keskus: Tuvastajate nimekiri</title>
    <meta http-equiv="Content-Type" content="text/html;charset=windows-1252" />
    <meta http-equiv="refresh" content="300"/>
    <link href="s4a.css" rel="stylesheet" type="text/css" /> 
  </head>

<body class="s4a-normal">
<div class="s4a">
<h3>Tuvastajate nimekiri</h3>
<a href="index.html">&uarr;</a>

<?php

$checked_prob = '';
if ($prob == $value_prob) {
	$checked_prob = 'checked';
}


$checked_active = '';
if ($active == $value_active) {
	$checked_active = 'checked';
}

print " | <form action=\"detectors.php\" method=\"get\">";
print "<input type=\"submit\" name=\"btn2\" value=\"V&auml;rskenda vaadet\"/>";
print "<br><input type=\"checkbox\" name=\"prob\" $checked_prob value=\"$value_prob\"/>";
print "<label for=\"prob\">Kuva vaid probleemsed tuvastajad</label>";
print "<br><input type=\"checkbox\" name=\"active\" $checked_active value=\"$value_active\"/>";
print "<label for=\"active\">Kuva vaid aktiivsed tuvastajad</label>";
print "</form>";


try {
	$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);


	$sql = 'SELECT t.active, t.errormask, t.droprate, t.shortname, t.longname, t.lastvisit, t.lastvisitrulever, t.lastvisitMAC, t.lastvisitIP, t.lastvisitver, t.updated_by, t.sid, o.name AS tuvastaja_org FROM Tuvastaja AS t LEFT JOIN Organisation as o ON o.sid = t.tuvastaja_org;';

	$query = null;
	$query = $pdo->prepare($sql);
	$query->execute();
	$rows = $query->fetchAll(PDO::FETCH_ASSOC);
	$rowcount = count($rows);

	print "<table class=\"s4a\">";

	print '<tr>';
	print '<th>L&uuml;hinimi</th>';
	print '<th>Aktiivne</th>';
	print '<th>Snort</th>';
	print '<th>TJPM</th>';
	print '<th>Organisatsioon</th>';
	print '<th>Kirjeldus</th>';
	print '<th>Viimati n&auml;htud</th>';
	print '<th>Kasutab reegleid</th>';
	print '<th>MAC-aadress</th>';
	print '<th>IP-aadress</th>';
	print '<th>Tarkvara ver.</th>';
	print '<th>Sert aktiivne</th>';
	print '</tr>';

	$td_class = 's4a-ok0';
	foreach ($rows as $row) {


		$sql = 'SELECT serial FROM Certificate WHERE active = 1 AND cert_tuvastaja = ' . $row['sid'] . ';';
		$query = null;
		$query = $pdo->prepare($sql);
		$query->execute();

		$certs = $query->fetchAll(PDO::FETCH_ASSOC);
		$certcount = count($certs);

		$has_problem = 0;
		$outline = '';

		if ($certcount < 0) {
			$certcount = 0;
		}

		if ($certcount) {
			$status = intval($row['active']);
		}
		else {
			$status = 0;
		}

		$snort = intval($row['errormask']);
		$droprate = intval($row['droprate']);

		$outline .= '<tr>';

		$detector = $row['shortname'];
		$sid = $row['sid'];

		$outline .= "<td class=$td_class>"."<a href=\"detector.php?sid=$sid\">".$detector."</a></td>";

		$is_active = 1;	
		$outline .= "<td class=\"$td_class centre\">";
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
			$is_active = 0;
		}
		$outline .= '</td>';

		$outline .= "<td class=\"$td_class centre\">";
	
		$intversion = intval(str_replace(".", "",$row['lastvisitver']));
		if ($intversion >= 472) {
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
		}
		else {
			if ($snort == 0) {
				$outline .= '<img src="images/icon_ok.png"></img>';
			}
			else {
				$outline .= '<img src="images/icon_error.gif"></img>';
				$has_problem = 1;
			}
		}
	
		$outline .= "<td class=\"$td_class centre\">";
		if ($droprate > 5) {
			$outline .= '<img src="images/icon_error.gif"></img>';
			$has_problem = 1;
		}
		else {
			$outline .= '<img src="images/icon_ok.png"></img>';
		}
		$outline .= '</td>';

		$outline .= "<td class=$td_class>".$row['tuvastaja_org']."</td>";
		$outline .= "<td class=$td_class>".$row['longname']."</td>";

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
				$outline .= "<td class=$td_class>".date('Y-m-d H:i', $row['lastvisit'])."</td>";
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
				$outline .= "<td class=$td_class>".date('Y-m-d H:i', $row['lastvisitrulever'])."</td>";
			}
		}

		if ($row['lastvisitMAC']) {
			$outline .= "<td class=\"$td_class\">".$row['lastvisitMAC']."</td>";
		}
		else {
			$outline .= "<td class=\"s4a-problem\"></td>";
			$has_problem = 1;
		}

		if ($row['lastvisitIP']) {
			$outline .= "<td class=\"$td_class\">".$row['lastvisitIP']."</td>";
		}
		else {
			$outline .= "<td class=\"s4a-problem\"></td>";
			$has_problem = 1;
		}

		if ($row['lastvisitver']) {
			$outline .= "<td class=\"$td_class\">".$row['lastvisitver']."</td>";
		}
		else {
			$outline .= "<td class=\"s4a-problem\"></td>";
		}

		$outline .= "<td class=\"$td_class centre\">";
		if ($certcount == 0) {
			$outline .= '<img src="images/icon_error.gif"></img>';
			$has_problem = 1;
		}
		else if ($certcount == 1) {
			$outline .= '<img src="images/icon_ok.png"></img>';
		}
		else {
			$outline .= '<img src="images/icon_alert.png"></img>';
			$has_problem = 1;
		}
		$outline .= '</td>';		
		$outline .= '</tr>';

		$should_show_active = 0;
		$should_show_prob = 0;

		if (($prob == 0) || (($prob == 1) && ($has_problem == 1))) {
			$should_show_prob = 1;
		}

		if (($active == 0) || (($active == 1) && ($is_active == 1))) {
			$should_show_active = 1;
		}

		if (($should_show_active == 1) && ($should_show_prob == 1)) {
			print $outline;
			if ($td_class == "s4a-ok0") {
				$td_class = "s4a-ok1";
			}
			else {
				$td_class = "s4a-ok0";
			}
		}
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

