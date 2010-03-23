<?php
/* Copyright (C) 2010, Cybernetica AS, http://www.cybernetica.eu/ */

define ('ROOTPATH', '');
define ('DETECTORSPATH', 'detectors');
define ('SIGSPATH', 'sigs');
define ('SIGMAPPATH', '/etc/s4a-map');

$det = isset($_GET['det']) ? $_GET['det'] : '';
$ds = isset($_GET['ds']) ? $_GET['ds'] : 'alerts';
$global = isset($_GET['global']) && is_numeric($_GET['global']) ? $_GET['global'] : 0;
$ff = isset($_GET['ff']) ? $_GET['ff'] : '';
$sig = isset($_GET['sig']) ? $_GET['sig'] : '';


$maxfile = 0;

$sids = array();
$handle = @fopen(SIGMAPPATH, "r");
if ($handle) {
	while (!feof($handle)) {
		$buffer = fgets($handle);
		$outp = explode("\t", $buffer, 4);
		if (count($outp) == 4) {
			$sids["$outp[1]\t$outp[2]"] = trim($outp[0]) . " " . trim($outp[3]);
			if ($outp[1] > $maxfile) {
				$maxfile = $outp[1];
			}
		}
	}
	fclose($handle);
}

$type = 0;

if ($det && ($sig != '')) {
	$type = 1; // üks konkreetne signatuur/tuvastaja paar: zoomer
}
else if ($det) {
	$type = 2; // üks konkreetne tuvastaja - kõik signatuurid
}
else if ($sig != '') {
	$type = 3; // üks konkreetne signatuur - kõik tuvastaj
}
else {
	$type = 0; // kõik tuvastajad - globaalinfo
}

if ($global) {
	$type = 4; // kõik signatuurid - globaalinfo 
}

$nextds = $ds;
if ($type == 0) {
	$nextds = "alerts";
}

if (($type == 2) || ($type == 3) || ($type == 4)) {
	$datasources = array("alerts" => "Alerdid",
				"intip" => "Nakatunud IP %",
				"extip" => "Seotud v&auml;lised IP'd",
				"srcdst" => "Erinevad SRC <-> DST paarid");
}
if ($type == 0) {
	$datasources = array("alerts" => "Alerdid", 
				"sigs" => "Signatuurid",
				"badratio" => "Nakatunud IP %",
				"extip" => "Seotud v&auml;lised IP'd");
}
?>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
	"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">

  <head>
    <title>S4A keskus: graafikud</title>
    <meta http-equiv="Content-Type" content="text/html;charset=windows-1252" />
    <meta http-equiv="refresh" content="300"/>
    <link href="s4a.css" rel="stylesheet" type="text/css" />
  </head>

  <body class="s4a-wide">

    <div id="bounding">
    <div id="header"> 
    <div id="insideheader">

    <table>

    <tr><td>
    <a href="index.html">&uarr;</a>
    <th class="header">Vaade
    <th class="header">Muuda
    <th class="header">Andmestik

    <tr><td rowspan="2"><th class="header" rowspan="1">

<?php

	if ($type == 0) {
		print "Tuvastajate &uuml;ldine seisund";
	}
	else if ($type == 1) {
	}
	else if ($type == 2) {
		print "&Uuml;he tuvastaja seisund";
	}
	else if ($type == 3) {
		$title = "This slot is empty";
		if (array_key_exists("$ff\t$sig", $sids)) { 
			$title = $sids["$ff\t$sig"];
		}

		print "Signatuur tuvastajates";
	}
	else if ($type == 4) {
		print "Signatuuride &uuml;ldine seisund";
	}

	print "<td class=\"header\">";

	if (($type == 0) || ($type == 2) || ($type == 3)) {
		print "<form action=\"observer.php\" method=\"get\">";
	   	print "<input type=\"hidden\" name=\"global\" value=\"1\">";
		print "<input type=\"submit\" name=\"btn1\" value=\"K&otilde;ik signatuurid\"/>";
		print "</form>";
	}


?>

    <td class="header" rowspan="2">


    <form action="observer.php" method="get">

    <input type="hidden" name="det" value="<?php print $det; ?>">
    <input type="hidden" name="sig" value="<?php print $sig; ?>">
    <input type="hidden" name="ff" value="<?php print $ff; ?>">
    <input type="hidden" name="global" value="<?php print $global; ?>">

<?php
	$active_ds_name;
	print "<select name=\"ds\">";
	foreach ($datasources as $ds_name => $ds_desc) {
		if (!strcmp($ds_name, $ds)) {
			$active_ds_name = $ds_desc;
			print "<option selected value=\"$ds_name\">$ds_desc</option>";
		}
		else {
			print "<option value=\"$ds_name\">$ds_desc</option>";
		}
	}
	print "</select>";
?>

    <br>
    <input type="submit" name="btn0" value="Vali andmestik"/> 
    </form>
    
    <tr>
    <th class="header"><?php print $active_ds_name; ?>

    <td class="header">

<?php
	if (($type == 2) || ($type == 3) || ($type == 4)) { 
		print "<form action=\"observer.php\" method=\"get\">";
		print "<input type=\"submit\" name=\"btn2\" value=\"K&otilde;ik tuvastajad\"/>";
		print "</form>";
	}
?>

    <tr><td><td class="header" colspan="4">

<?php
	if ($type == 0) {
	}
	else if ($type == 1) {
	}
	else if ($type == 2) {
		print "\"$det\"";
	}
	else if ($type == 3) {
		$title = "This slot is empty";
		if (array_key_exists("$ff\t$sig", $sids)) { 
			$title = $sids["$ff\t$sig"];
		}
		print "\"$title\"";
	}
	else if ($type == 4) {
	}
?>

    </table>
    </div>
    </div>
    
    <div id="main">

<?php

$detectors = array();
$detectordir = scandir(ROOTPATH . DETECTORSPATH);
foreach ($detectordir as $key => $value) {
	if (($value != '.') && ($value != '..') && ($value != 's4a-detector')) {
		$detectors[] = $value;
	}
}
sort($detectors);

$cachebuster = time();
 
if ($type == 0) {
	foreach ($detectors as $key => $value) {
		$imgname = DETECTORSPATH . "/$value/img-global-$ds.png";
		if (is_readable(ROOTPATH . $imgname)) {
			print "<a href =\"observer.php?det=$value&ds=$nextds\"><img class=\"det s4a\" src=\"$imgname?$cachebuster\" title=\"$value\"></img></a>";
		}
		else {
			print "<img class=\"det s4a\" src=\"na-det.png\" title=\"$value\"></img>";
		}
	}
}
else if ($type == 1) {
}
else if ($type == 2) {
	for ($ii = 0; $ii <= $maxfile; $ii++) {
		$imgname = DETECTORSPATH . "/$det/img-$ii-$ds.png";
		if (is_readable(ROOTPATH . $imgname)) {
			print "<img class=\"sigs s4a\" src=\"$imgname?$cachebuster\" usemap='#map$ii'></img>";
			print "<map name=\"map$ii\">"; 
			for ($row = 0; $row < 4; $row++) {
				for ($col = 0; $col < 25; $col++) {
					$lx = $col * 72;
					$ly = $row * 18;
					$ux = $lx + 72;
					$uy = $ly + 18;
					$sig = $row * 25 + $col;
					$title = "This slot is empty";
					if (array_key_exists("$ii\t$sig", $sids)) { 
						$title = $sids["$ii\t$sig"];
					}
					print "<area shape=\"rect\" coords=\"$lx,$ly,$ux,$uy\" alt=\"$title\" href=\"observer.php?ds=$ds&ff=$ii&sig=$sig\" title=\"$title\">";
				}
			}
			print "</map>";
		}
		else {
			print "<img class=\"sigs s4a\" src=\"na-sig.png\"></img>";
		}
	}
}
else if ($type == 3) {
		// TODO img suurus sõltub detektorite arvust
		$imgname = SIGSPATH . "/$ff/img-$sig-$ds.png";
		if (is_readable(ROOTPATH . $imgname)) {
			print "<img class=\"sigs s4a\"src=\"$imgname?$cachebuster\" usemap='#map'></img>";
			print "<map name=\"map\">";
			$max = count($detectors);
			$row = 0;
			$col = 0;
			$ii = 0;
			while ($ii < $max) {
				if ($col == 25) {
					$col = 0;
					$row++;
				}

				$lx = $col * 72;
				$ly = $row * 18;
				$ux = $lx + 72;
				$uy = $ly + 18;
				$det = $detectors[$ii];
				print "<area shape=\"rect\" coords=\"$lx,$ly,$ux,$uy\" alt=\"$det\" href=\"observer.php?ds=$ds&det=$det\" title=\"$det\">";


				$col++;
				$ii++;
			}
			print "</map>";
		}
		else {
			print "<img class=\"sigs s4a\" src=\"na-sig.png\"></img>";
		}
}
else if ($type == 4) {
	for ($ii = 0; $ii <= $maxfile; $ii++) {
		$imgname = DETECTORSPATH . "/s4a-detector/img-$ii-$ds.png";
		if (is_readable(ROOTPATH . $imgname)) {
			print "<img class=\"sigs s4a\" src=\"$imgname?$cachebuster\" usemap='#map$ii'></img>";
			print "<map name=\"map$ii\">"; 
			for ($row = 0; $row < 4; $row++) {
				for ($col = 0; $col < 25; $col++) {
					$lx = $col * 72;
					$ly = $row * 18;
					$ux = $lx + 72;
					$uy = $ly + 18;
					$sig = $row * 25 + $col;
					$title = "This slot is empty";
					if (array_key_exists("$ii\t$sig", $sids)) { 
						$title = $sids["$ii\t$sig"];
					}
					print "<area shape=\"rect\" coords=\"$lx,$ly,$ux,$uy\" alt=\"$title\" href=\"observer.php?ds=$ds&ff=$ii&sig=$sig\" title=\"$title\">";
				}
			}
			print "</map>";
		}
		else {
			print "<img class=\"sigs s4a\" src=\"na-sig.png\"></img>";
		}
	}
}
?>

    </div>
    </div>
  </body>
</html>

