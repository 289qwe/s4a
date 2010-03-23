<?php

/* Copyright (C) 2010, Cybernetica AS, http://www.cybernetica.eu/ */


if ($_SERVER['REMOTE_USER'] == 'webroot') {
	define ('S4A_ROOT', true);
}
defined('S4A_ROOT') or die('www.cert.ee');

$sid = isset($_POST['sid']) ? $_POST['sid'] : '';
$action = isset($_POST['action']) ? $_POST['action'] : '';

if ($action == 1) {
	$action = 0; 
}
else {
	$action = 1;
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
    <title>S4A j&auml;lgimisliides</title>
    <meta http-equiv="Content-Type" content="text/html;charset=windows-1252" />
<?php
    print "<meta http-equiv=\"refresh\" content=\"1;url=detector.php?sid=$sid\"/>";
?>
    <link href="s4a.css" rel="stylesheet" type="text/css" /> 
  </head>

<body class="s4a-normal">

<?php

try {
	$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

	$sql = 'UPDATE Tuvastaja SET active='.$action.', updated_by="' . 'webadmin' . '" WHERE sid=' . intval($sid) . ';';

	$query = null;
	$query = $pdo->prepare($sql);
	$query->execute();
	$row = $query->fetch(PDO::FETCH_ASSOC);
}

catch (PDOException $e) {
}
	
unset($pdo);
?>

</body>
</html>

