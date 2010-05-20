<?php
/* Copyright (C) 2010, Cybernetica AS, http://www.cybernetica.eu/ */

/*
 * Statistics viewer script
 */

// Include common functions
require_once 'statview_common.inc';

// Main routine begins here

error_reporting(E_ALL);


$preproc = "";
if (isset($_GET['preproc'])) {
	$preproc = "checked";
} 

$threshold = isset($_GET['threshold']) && is_numeric($_GET['threshold']) ? $_GET['threshold'] : 0;
$line_count = isset($_GET['count']) && is_numeric($_GET['count']) ? $_GET['count'] : 25;
$page_type = isset($_GET['type']) && is_numeric($_GET['type']) ? $_GET['type'] : 0;

$sig = isset($_GET['sig']) ? $_GET['sig'] : "";
$src = isset($_GET['src']) ? $_GET['src'] : "";
$dst = isset($_GET['dst']) ? $_GET['dst'] : "";

$year_dir = isset($_GET['yy']) ? $_GET['yy'] : "";
$day_dir = isset($_GET['md']) ? $_GET['md'] : "";

$dbhh = dbopen("header");

if (!$dbhh) {
	print_error();
	exit;
}

print_head();

?>
<div class="content">


<?php

switch ($page_type) {
	case 0:
		// Show all alerts
		generate_all_sig_src_dst();
		break;
	case 1:
		// Show alerts by specific signatures
		generate_all_by_one($dbhh, "Alerte p&otilde;hjustanud signatuurid", "signatuur", "s4", "sig", "");
		break;
	case 2: 
		// Show alerts by specific source address
		generate_all_by_one($dbhh, "Alerte p&otilde;hjustanud l&auml;hteaadressid", "IP", "s5", "src", "s4a-ip");
		break;
	case 3:
		// Show alerts by specific destination address
		generate_all_by_one($dbhh, "Alerte p&otilde;hjustanud sihtaadressid", "IP", "s6", "dst", "s4a-ip");
		break;
	case 4:
		// Show sources of specific signature
		generate_one_sig($sig);
		break;
	default:
		break;
}
?>
</div>
<?php
print_summary($dbhh);
print_footer();
dbclose($dbhh);

// Main routine ends here

/*
 * Functions section begin here
 */

function logopen($file)
{
	$logroot = "/tuvastaja/data/snort-logs";
	$logfile = sprintf("%s/%s", $logroot, $file);

	if (!is_dir($logroot)) {
		return;
	}
	if (!file_exists($logfile)) {
		return;
	}

	return fopen($logfile, "r");
}

function print_form()
{

?>
<div class="box">
<h3 class="s4a">Filter</h3>
<form method="GET">
<input type="hidden" name="type" value="<?php print $GLOBALS['page_type']?>" />
<input type="hidden" name="yy" value="<?php print $GLOBALS['year_dir']?>" />
<input type="hidden" name="md" value="<?php print $GLOBALS['day_dir']?>" />
<input type="hidden" name="sig" value="<?php print $GLOBALS['sig']?>" />
<label>
<input id="id_preproc" class="input-text" type="checkbox" name="preproc" value="preproc" <?php print $GLOBALS['preproc'] ?> />
<span class="right">Kuva preprotsessorid:</span>
</label>
<label>
<input id="id_count" class="input-text" type="text" name="count" value="<?php print $GLOBALS['line_count']?>" size="4"/>
<span class="right">Top:</span>
</label>
<label>
<input id="id_threshold" class="input-text" type="text" name="threshold" value="<?php print $GLOBALS['threshold']?>" size="4"/>
<span class="right">L&auml;vend:</span>
</label>
<?php
	if ($GLOBALS['page_type'] == 0) {			# Filter is only available to certain queries
?>
<label>
<span class="left">L&auml;hteaadress:</span>
<input id="id_src" class="input_text" type="text" name="src" value="<?php print $GLOBALS['src']?>" size="15"/>
</label>
<label>
<span class="left">Sihtaadress:</span>
<input id="id_dst" class="input_text" type="text" name="dst" value="<?php print $GLOBALS['dst']?>" size="15"/>
</label>
<?php
	}
	else {
?>
<input type="hidden" name="src" value="<?php print $GLOBALS['src']?>" />
<input type="hidden" name="dst" value="<?php print $GLOBALS['dst']?>" />
<?php
	}
?>
<div>
<input class="submit" type="submit" name="submit" value="Otsi"/>
</div>
</form>
</div>
<?php
}

function db_read_into_array_and_sort($dbh) {
	$data = array();
	for ($key = dba_firstkey($dbh); $key != false; $key = dba_nextkey($dbh)) {
		$data[$key] = dba_fetch($key, $dbh);
	}
	arsort($data);
	return $data;
}

function generate_one_sig($sig) {
	if (empty($sig)) {
		return;
	}
	$dbh = dbopen("s7");
	$signame = dbfetch($sig, $dbh);
	dbclose($dbh);

?>
<h3 class="s4a">Signatuuri allikad</h3>

<input type="button" id="show-btn" value="<?php print $signame?>"/><br/><br/>

<?php
	$os = time() - 172800;
	$oe = time();
?>
<script>
var old_start_time = <?php print $os?>;
var old_end_time = <?php print $oe?>;
var sig_id = <?php print "\"$sig\""?>;
var signature = <?php print "\"$signame\""?>;
</script>

<div>
<div>
<?php

	generate_one_sig_($sig, $signame, "L&auml;hteaadressid", "s2", "src");
?>
</div>
<div>
<?php
	generate_one_sig_($sig, $signame, "Sihtaadressid", "s3", "dst");
?>
</div>
</div>
<?php
}

function generate_one_sig_($sig, $signame, $caption, $database, $type) {
	$dbh = dbopen($database);
?>

<table class="s4a-floating-table">
<caption class="s4a"><?php print $caption?></caption>
<tr class="s4a">
<th class="s4a">jrk.</th>
<th class="s4a">ip</th>
<th class="s4a">alerte</th>
</tr>
<?php
	$data = db_read_into_array_and_sort($dbh);
	$count = 0;
	foreach ($data as $key => $alerts) {
		if ($alerts < $GLOBALS['threshold']) {
			continue;
		}
		$keyparts = explode(",", $key);
		if ($keyparts[0] != $sig) {
			continue;
		}
		$src_dst = $keyparts[1];

		$count++;
		// Break after exceeding line count limit
		if ($GLOBALS['line_count'] > 0 && $count > $GLOBALS['line_count']) {
			break;
		}

		$url = sprintf("%s&%s=%s", prepare_url(0), $type, $src_dst);
?>
<tr class="s4a">
<td class="s4a s4a-jrk"><?php print $count?></td>
<td class="s4a s4a-ip"><a title="<?php print $src_dst?>" href="<?php print $url?>"><?php print $src_dst?></a></td>
<td class="s4a s4a-alerts"><?php print $alerts?></td>
</tr>
<?php
	}
?>
</table>
<?php
	dbclose($dbh);
}

function generate_all_by_one($dbhh, $heading, $heading2, $database, $type, $css) {
	$dbh = dbopen($database);
	$db7h = "";

	if ($type == "sig") {
		$db7h = dbopen("s7");
	}
?>
<table class="s4a" title="<?php print $heading?>">
<thead>
<tr class="s4a">
<th class="s4a">jrk.</th>
<th class="s4a"><?php print $heading2?></th>
<th class="s4a">alerte</th>
<th class="s4a">%</th>
<?php
if ($css) {
?>
<th class="s4a"></th>
<?php
}
?>
</tr>
</thead>

<tbody>
<?php
	$data = db_read_into_array_and_sort($dbh);
	$count = 0;
	foreach($data as $key => $alerts) {
		if ($type == "sig" && $GLOBALS['preproc'] != "checked") {
			$keyparts = explode(":", $key);
			if ($keyparts[0] != 1) {
				continue;
			}
		}

		if ($alerts < $GLOBALS['threshold']) {
			continue;
		}
		$count++;
		// Break after exceeding line count limit
		if ($GLOBALS['line_count'] > 0 && $count > $GLOBALS['line_count']) {
			break;
		}
		$percent = sprintf("%.2f", ($alerts/dbfetch('TOTAL', $dbhh)) * 100);
		$url = sprintf("%s&%s=%s", prepare_url($type == "sig" ? 4 : 0), $type, $key);
		$href = ($type == "sig") ? dbfetch($key, $db7h) : $key;
?>
<tr class="s4a">
<td class="s4a s4a-jrk"><?php print $count?></td>
<td class="s4a <?php print $css ?>"><a title="<?php print $href?>" href="<?php print $url?>"><?php print $href?></a></td>
<td class="s4a s4a-alerts"><?php print $alerts?></td>
<td class="s4a s4a-jrk"><?php print $percent?></td>
<?php
if ($css) {
?>
<td class="s4a"></td>
<?php
}
?>
</tr>
<?php
	}
?>
</tbody>
</table>
<?php
	dbclose($dbh);
	if ($type == "sig") {
		dbclose($db7h);
	}
}

function generate_all_sig_src_dst() {

	$db0h = dbopen("s0");
	$db7h = dbopen("s7");
?>
<table class="s4a" title="Alertide &uuml;levaade">
<thead>
<tr class="s4a">
<th class="s4a">jrk.</th>
<th class="s4a">signatuur</th>
<th class="s4a">l&auml;hteaadress</th>
<th class="s4a">sihtaadress</th>
<th class="s4a">alerte</th>
</tr>
</thead>
<tbody>
<?php
	$data = db_read_into_array_and_sort($db0h);
	$count = 0;
	foreach ($data as $key => $alerts) {

		if ($GLOBALS['preproc'] != "checked") {
			$keyparts1 = explode(",", $key);
			$keyparts = explode(":", $keyparts1[2]);
			if ($keyparts[0] != 1) {
				continue;
			}
		}


		if ($alerts < $GLOBALS['threshold']) {
			continue;
		}
		$keyparts = explode(",", $key);
		$src = $keyparts[1];
		$dst = $keyparts[0];
		$sig = $keyparts[2];
		if (!empty($GLOBALS['dst']) && $dst != $GLOBALS['dst']) {
			continue;
		}
		if (!empty($GLOBALS['src']) && $src != $GLOBALS['src']) {
			continue;
		}
		if (!empty($GLOBALS['sig']) && $sig != $GLOBALS['sig']) {
			continue;
		}
		$count++;
		// Break after exceeding line count limit
		if ($GLOBALS['line_count'] > 0 && $count > $GLOBALS['line_count']) {
			break;
		}

		$src_url = prepare_url(0) . "&src=" . $src;
		$dst_url = prepare_url(0) . "&dst=" . $dst;
		$sig_url = prepare_url(0) . "&sig=" . $sig;
?>
<tr class="s4a">
<td class="s4a s4a-jrk"><?php print $count?></td>
<td class="s4a"><a title="<?php print $sig ?>" href="<?php print $sig_url?>"><?php print dbfetch($sig, $db7h)?></a></td>
<td class="s4a s4a-ip"><a title="<?php print $src ?>" href="<?php print $src_url?>"><?php print $src?></a></td>
<td class="s4a s4a-ip"><a title="<?php print $dst ?>" href="<?php print $dst_url?>"><?php print $dst?></a></td>
<td class="s4a s4a-alerts"><?php print $alerts?></td>
</tr>
<?php
	}
?>
</tbody>
</table>
<?php
	dbclose($db0h);
	dbclose($db7h);
}

function print_head() {
?>
<html xmlns="http://www.w3.org/1999/xhtml" lang="en-US" xml:lang="en-US">
<head>
<title>Vaatleja</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />

<?php 
	if ($GLOBALS['page_type'] == 4) {
		print_head4();
	}
?>


<link rel="stylesheet" type="text/css" href="statview.css" />
</head>
<?php
}

function print_head4() {
?>

<link rel="stylesheet" type="text/css" href="../ext3/resources/css/ext-all.css"/> 
<script type="text/javascript" src="../ext3/adapter/ext/ext-base.js"></script>
<script type="text/javascript" src="../ext3/ext-all.js"></script>
<script language="javascript" src="js/rrdzoom.js"></script>
<style type="text/css">
    .x-panel-body p {
        margin: 10px;
        font-size: 12px;
    }
</style>

<?php
}



function print_summary($dbhh) {
?>
<div id="navalpha">
<div class="s4a-box">
<dl class="s4a">
<?php
	if (dbfetch('TOTAL', $dbhh)) {
		echo prepare_dl_line("Logi algus", 'STARTTIME', $dbhh);
		echo prepare_dl_line("Logi l&otilde;pp", 'ENDTIME', $dbhh);
	}
	echo prepare_dl_line("Viimane anal&uuml;&uuml;s", 'PROC_TIME', $dbhh);
	echo prepare_dl_line("T&ouml;&ouml;deldud kirjeid", 'NEW_LINES', $dbhh);
	echo prepare_dl_line("Uusi alerte", 'NEW_ALERTS', $dbhh);
	echo prepare_dl_line("Alerte", 'TOTAL', $dbhh, prepare_url(0));
	echo prepare_dl_line("Signatuure", 'SIG_COUNT', $dbhh, prepare_url(1));
	echo prepare_dl_line("L&auml;hteaadresse", 'SRC_COUNT', $dbhh, prepare_url(2));
	echo prepare_dl_line("Sihtaadresse", 'DST_COUNT', $dbhh, prepare_url(3));
?>
</dl>
</div>
<?php
print_form();
?>

</div>
<?php

}

function prepare_dl_line($name, $variable, $handler, $url = "")
{
	$abeg = $aend = "";
	if ($url) {
		$abeg = "<a href=\"".$url."\">";
		$aend = "</a>";
	}
?>
<dt><?php print $abeg.$name.$aend?>:</dt>
<dd class="s4a"><?php print dbfetch($variable, $handler)?></dd>
<?php
}

function prepare_url($type)
{

	$tmp_url = sprintf("%s?type=%d&count=%d&threshold=%d&yy=%s&md=%s", 
			$_SERVER['PHP_SELF'], $type, $GLOBALS['line_count'], $GLOBALS['threshold'], $GLOBALS['year_dir'], $GLOBALS['day_dir']);

	if ($GLOBALS['preproc'] == "checked") {
		$tmp_url .= "&preproc=preproc";
	}
	return $tmp_url;
}

function print_error() {
	print_head();
?>
<b>Statistikafaile ei ole veel loodud</b>
<?php
	print_footer();
}

# print the footer (needed for html)
function print_footer() {
?>
</html>
<?php
}

?>
