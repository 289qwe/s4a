<?php
/* Copyright (C) 2010, Cybernetica AS, http://www.cybernetica.eu/ */

error_reporting(E_ALL);

define ('SD_ADM', true);
define ('SD_CONFIG_FILE', 'sd_config.php');

preg_match( '/^.+\//', $_SERVER['SCRIPT_FILENAME'], $curpath);
require_once( $curpath[0] . SD_CONFIG_FILE );
require_once( $curpath[0] . $CONFIG['system_lang_file'] );

$log = isset($_GET['log']) && is_numeric($_GET['log']) ? $_GET['log'] : 0;
$maxlines = isset($_GET['lines']) && is_numeric($_GET['lines']) ? $_GET['lines'] : 500;
$logfile = isset($_GET['file']) && is_string($_GET['file']) ? $_GET['file'] : 'updater';

print_head();

global $LOGFILES;

$path = $LOGFILES[$logfile];
if (!$path) {
	$path = $LOGFILES['updater'];
}
		
if ($log > -1) {
	$path  .= '.' . $log;
}
		
if (file_exists($path)) {
	$fsize = round(filesize($path)/1024/1024, 2);
	if ($fsize) {
		echo "Faili suurus on {$fsize} megabaiti.<br/>";
	}
	else {
		$fsize = round(filesize($path)/1024, 2);
		echo "File suurus on {$fsize} kilobaiti.<br/>";
	}
	echo "Kuvatakse maksimaalselt $maxlines rida.<br/>";
	echo "NB! Logi kuvatakse v&auml;rskem info eespool.<br/>";
	echo "<pre>";
	$lines = display_file($path, $maxlines);
	echo "</pre>";
} 
else {
	echo UI_SD_NO_LOG_AVAILABLE;
}

print_footer();

// Main routine ends here

/*
 * Functions section begin here
 */

function print_head() {
?>
<html xmlns="http://www.w3.org/1999/xhtml" lang="en-US" xml:lang="en-US">
<head>
<title>Logivaatur</title>
<link rel="stylesheet" type="text/css" href="logview.css" />
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
</head>
<body>
<?php
}

function display_file($file, $lines) {
	$run_limit = ini_get('max_execution_time') - 1;
	$start_time = time();
	$handle = fopen($file, "r");
	$linecounter = $lines;
	$pos = -2;
	$beginning = false;
	while ($linecounter > 0) {
		if (time() - $start_time > $run_limit) {
			echo "NB! --- skripti t&ouml;&ouml; peatati --- NB!\n";
			echo "P&auml;ringu t&ouml;&ouml;tlemine katkestati, kuna see kestis &uuml;le lubatud aja $run_limit sekundit.\n"; 
			echo "J&otilde;udsin n&auml;idata " . ($lines - $linecounter) . " rida.";
			break;
		}

		$t = " ";
		while ($t != "\n") {
			if(fseek($handle, $pos, SEEK_END) == -1) {
				$beginning = true; 
				break; 
			}
			$t = fgetc($handle);
			$pos --;
		}
		$linecounter --;
		if ($beginning) {
			rewind($handle);
		}
		$output = fgets($handle);
		echo str_replace("<", "&lt;", $output);
		if ($beginning) break;
	}
	fclose ($handle);
}

# print the footer (needed for html)
function print_footer() {
?>
</body>
</html>
<?php
}

?>
