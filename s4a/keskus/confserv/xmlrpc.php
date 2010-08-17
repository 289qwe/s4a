<?php

/*
 * Copyright (C) 2010, Cybernetica AS, http://www.cybernetica.eu/
 * */

define ('CS_ADM', true);
define ('XMLRPC_ERR_UNABLE_TO_CONNECT_TO_DB_TEXT', 'Internal database error!');
define ('XMLRPC_ERR_UNABLE_TO_CONNECT_TO_DB_CODE', '001');
define ('XMLRPC_ERR_DB_QUERY_FAILED_TEXT', 'Internal database error!');
define ('XMLRPC_ERR_DB_QUERY_FAILED_CODE', '002');
define ('XMLRPC_ERR_INACTIVE_CERTIFICATE_TEXT', 'Inactive or unknown certificate!');
define ('XMLRPC_ERR_INACTIVE_CERTIFICATE_CODE', '003');
define ('XMLRPC_ERR_AMBIGUOUS_MAC_TEXT', 'Supplied MAC does not match last update MAC!');
define ('XMLRPC_ERR_AMBIGUOUS_MAC_CODE', '004');
define ('XMLRPC_ERR_EXPIRED_CERTIFICATE_TEXT', 'Certificate has been expired!');
define ('XMLRPC_ERR_EXPIRED_CERTIFICATE_CODE', '005');

define ('RULE_DIR_PATH', '/confserv/signatures/');
define ('UPDATE_DIR_PATH', '/confserv/patches/');
define ('DB_FILE', 'sqlite:/database/s4aconf.db');

define ('S4A_PATH', '/tmp/s4a');
define ('TIME_QUANTUM', 300);

define ('REQUEST_INTERVAL', 3600); // 600sec = 10min  This is used to find duplicate identities due to misconfiguration

/*
 * loeme failist esimese rea ja tagastame selle.
 * Kui faili pole siis tühi strig, see on normaalne seis
 */
function string_fromfile($filename)
{
	$value = '';
	if (file_exists($filename)) {
		$handle = @fopen($filename, "r");
		if ($handle) {
			# Huvitab ainult esimene rida
			$value = trim(fgets($handle, 4096));
			fclose($handle);
		}
	}

	return($value);
}

function get_current_xlevel($path,$basever)
{
	$value = string_fromfile($path."current-".$basever);
	if ($value == "") {
		return(0);
	} 
	else {
		return($value);
	}
}

function int2string($int, $numbytes=PHP_INT_SIZE)
{
	$str = "";
	for ($ii = 0; $ii < $numbytes; $ii++) {
		$str .= chr($int % 256);
		$int = $int / 256;
	}
	return $str;
}

function s4a_send($ss, $buf, $buf_len)
{
	$offset = 0;
	while ($offset < $buf_len) {
		$sent = socket_write($ss, substr($buf, $offset), $buf_len - $offset);
		if ($sent === false) {
			// Error occurred, break the while loop
			break;
		}
		$offset += $sent;
	}

	if ($offset < $buf_len) {
		$errorcode = socket_last_error();
		$errormsg = socket_strerror($errorcode);
//		echo "SENDING ERROR: $errormsg";
	} 
	else {
		// Data sent ok
	} 
}

function tuvastaja_stresstest($method_name, $params, $app_data)
{
	$tuvastaja_shortname = $params[0]['shortname'];
	$s4a_message = sprintf("%s\n", $tuvastaja_shortname);
	foreach ($params[0]['perruledata'] as $metrics_id => $metrics_data) {
		$dataelem = sprintf("%s\t%d\t%f\t%d\t%d\n", $metrics_data['sid'],
							$metrics_data['alerts'], 
							$metrics_data['intip'], 
							$metrics_data['extip'], 
							$metrics_data['srcdst']);
		$s4a_message .= $dataelem;
	}

	{
		$metrics_data = $params[0]['globaldata'];
		$dataelem = sprintf("global\t%d\t%d\t%f\t%d\n", $metrics_data['alerts'], 
							$metrics_data['sigs'], 
							$metrics_data['badratio'], 
							$metrics_data['extip']);
		$s4a_message .= $dataelem;
	}

	$s4a_message_len = strlen($s4a_message) + 1;  // PHP_INT_SIZE  $s4a_message

	$sock = socket_create(AF_UNIX, SOCK_STREAM, 0);
	if ($sock == FALSE) {
		syslog(LOG_WARNING, "socket_create");
	}

	if (!socket_connect($sock, S4A_PATH)) {
		syslog(LOG_WARNING, "socket_connect");
	}

	s4a_send($sock, int2string($s4a_message_len), PHP_INT_SIZE);
	s4a_send($sock, $s4a_message."\0", $s4a_message_len);
	socket_close($sock);

	$retstr = array("everything" => "ok");

	return $retstr;
}

function tuvastaja_rrdfunc($method_name, $params, $app_data)
{
	$ssl_client_cert_serial = $_SERVER['SSL_CLIENT_CERT_SERIAL'];
	$ssl_client_cn = $_SERVER['SSL_CLIENT_CN'];
	$visitorIP = $_SERVER['REMOTE_ADDR'];
	$ssl_client_cert_end = $_SERVER['SSL_CLIENT_CERT_END'];
	$client_end_time = strtotime("$ssl_client_cert_end");
	$server_time = time();
	
	$dbh = new PDO(DB_FILE);

	$retstr = '';

	if (!$dbh) {
		syslog(LOG_ERR, "Unable to open database connection");
		return array('faultString' => XMLRPC_ERR_UNABLE_TO_CONNECT_TO_DB_TEXT, 
			'faultCode' => XMLRPC_ERR_UNABLE_TO_CONNECT_TO_DB_CODE);
	}

	$dbh->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
		
	try {
		if ($client_end_time < $server_time) {
			$set_inactive=("UPDATE Certificate SET active = 0 WHERE serial = '$ssl_client_cert_serial';");
                	$dbh->exec($set_inactive);
			
			syslog(LOG_ERR, "Client certificate has been expired");
			return array('faultString' => XMLRPC_ERR_EXPIRED_CERTIFICATE_TEXT,
					'faultCode' => XMLRPC_ERR_EXPIRED_CERTIFICATE_CODE);
		}
		
		$sql = 'SELECT Certificate.active as cactive, '.
			'Tuvastaja.shortname as tshortname, '.
			'Tuvastaja.active as tactive, '.
			'Tuvastaja.sid, Tuvastaja.lastvisit, Tuvastaja.lastvisitMAC  '.
			'FROM Certificate,Tuvastaja '.
			'WHERE Certificate.cert_tuvastaja=Tuvastaja.sid and Certificate.serial = :ser';
		$sth = $dbh->prepare($sql, array(PDO::ATTR_CURSOR => PDO::CURSOR_FWDONLY));
		$sth->execute(array(':ser' => $ssl_client_cert_serial));

		if ($row = $sth->fetch(PDO::FETCH_ASSOC)) {
			$cert_is_active = intval($row['cactive']);
			$tuvastaja_is_active = intval($row['tactive']);
			$sid = intval($row['sid']);
			$lastvisit = intval($row['lastvisit']);
			$lastvisitMAC = $row['lastvisitMAC'];
			$tuvastaja_shortname = $row['tshortname'];
			if ($cert_is_active == 0) {
				syslog(LOG_INFO, "Connection with Inactive certificate");
				$retstr = array('faultString' => XMLRPC_ERR_INACTIVE_CERTIFICATE_TEXT, 
					'faultCode' => XMLRPC_ERR_INACTIVE_CERTIFICATE_CODE);

			}
			if ($tuvastaja_is_active == 0) {
				syslog(LOG_INFO, "Connection from Inactive Tuvastaja");
				$retstr = array('faultString' => XMLRPC_ERR_INACTIVE_CERTIFICATE_TEXT, 
					'faultCode' => XMLRPC_ERR_INACTIVE_CERTIFICATE_CODE);
			}
		} 
		else {
			syslog(LOG_WARNING, "Connection with Unknown certificate?");
			$retstr = array('faultString' => XMLRPC_ERR_INACTIVE_CERTIFICATE_TEXT, 
				'faultCode' => XMLRPC_ERR_INACTIVE_CERTIFICATE_CODE);

		}
		$sth->closeCursor();
	
		if ($retstr) {
			unset($dbh);
			return $retstr;
		}

		$currentMAC = $params[0]['mymac'];
		if (($lastvisitMAC != '') && (($lastvisitMAC != $currentMAC) 
				&& (($lastvisit + REQUEST_INTERVAL) > time()))) {
			$tmp = time() - $lastvisit;
			syslog(LOG_INFO, "MAC change from $lastvisitMAC to $currentMAC in ".$tmp." sec");
			unset($dbh);
			return array('faultString' => XMLRPC_ERR_AMBIGUOUS_MAC_TEXT, 
					'faultCode' => XMLRPC_ERR_AMBIGUOUS_MAC_CODE);
		}

		$time_difference_exact = time() - (integer)$params[0]['currenttime'];
		$time_difference = $time_difference_exact - ($time_difference_exact % TIME_QUANTUM);
		syslog(LOG_INFO,"Tuvastaja time difference is $time_difference_exact (rounding to $time_difference)");

		$s4a_message = sprintf("%s\n", $tuvastaja_shortname);

		if (array_key_exists('perruledata', $params[0])) {
			foreach ($params[0]['perruledata'] as $metrics_id => $metrics_data) {
				$dataelem = sprintf("%s\t%d\t%f\t%d\t%d\n", $metrics_data['sid'],
									$metrics_data['alerts'], 
									$metrics_data['intip'], 
									$metrics_data['extip'], 
									$metrics_data['srcdst']);

				$s4a_message .= $dataelem;
			}
		}


		if (array_key_exists('globaldata', $params[0])) {
			$metrics_data = $params[0]['globaldata'];
			$dataelem = sprintf("global\t%d\t%d\t%f\t%d\n", $metrics_data['alerts'], 
								$metrics_data['sigs'], 
								$metrics_data['badratio'], 
								$metrics_data['extip']);

			$s4a_message .= $dataelem;
		}

		$s4a_message_len = strlen($s4a_message) + 1;  // PHP_INT_SIZE  $s4a_message

		$sock = socket_create(AF_UNIX, SOCK_STREAM, 0);
		if ($sock == FALSE) {
			syslog(LOG_WARNING, "socket_create");
		}

		if (!socket_connect($sock, S4A_PATH)) {
			syslog(LOG_WARNING, "socket_connect");
		}

		syslog(LOG_DEBUG, $s4a_message_len);
		s4a_send($sock, int2string($s4a_message_len), PHP_INT_SIZE);
		syslog(LOG_DEBUG, $s4a_message);
		s4a_send($sock, $s4a_message."\0", $s4a_message_len);
		socket_close($sock);

		$softversion = get_current_xlevel(UPDATE_DIR_PATH, $params[0]['baseversion']);
		$ruleversion = get_current_xlevel(RULE_DIR_PATH, 'rules');

		$tuvver = $params[0]['baseversion'].".".$tuvver = $params[0]['patchlevel'];
		$timestamp = time();
		$errormask = 0;
		if ($params[0]['monitoringinfo']['snortstatus']) {
			# snortstatus on 1. bitt
			$errormask = $errormask | 0x1;
		}
		$query = sprintf("UPDATE Tuvastaja SET lastvisit = %s, 
					lastvisitMAC = %s, 
					lastvisitver = %s, 
					lastvisitIP = %s, 
					errormask = %s  WHERE sid = $sid;",
					$dbh->quote($timestamp), $dbh->quote($currentMAC),
					$dbh->quote($tuvver), $dbh->quote($visitorIP), $dbh->quote($errormask));
		$count = $dbh->exec($query);

		$retstr = array("softversion"	  => $softversion, 
				"ruleversion" 	  => $ruleversion, 
				"time_difference" => $time_difference_exact);

	} 
	catch (PDOException $e) {
		syslog(LOG_ERR, sprintf("Database query failed with error %d: %s", $e->getCode(), $e->getMessage()));
		$retstr = array('faultString' => XMLRPC_ERR_DB_QUERY_FAILED_TEXT, 
			'faultCode' => XMLRPC_ERR_DB_QUERY_FAILED_CODE);
	}

	if ($dbh) {
		unset($dbh);
	}
	
	return $retstr;
}

function execute($command, &$ret)
{
	$ret = array();
	$retval = 0;

	$goodcommand = escapeshellcmd($command);

	exec(sprintf("%s 2>&1", $goodcommand), $ret, $retval);
	if ($retval == 0) {
		syslog(LOG_DEBUG, "Executed: $goodcommand (ended normally)");
		return 0;
	}
	syslog(LOG_ERR, "Executed: $goodcommand (ended abnormally retval=$retval)");
	foreach ($ret as $nr => $retline) {
		syslog(LOG_INFO, "Line $nr: $retline");
	}
	return $retval;
}

openlog($_SERVER['SSL_CLIENT_CERT_SERIAL'], LOG_NDELAY, LOG_LOCAL3);
$xmlrpc_server = xmlrpc_server_create();
xmlrpc_server_register_method($xmlrpc_server, "detector.rrdupdate", "tuvastaja_rrdfunc");
#xmlrpc_server_register_method($xmlrpc_server, "detector.rrdupdate", "tuvastaja_stresstest");
xmlrpc_server_register_method($xmlrpc_server, "tuvastaja.hello", "tuvastaja_rrdfunc");
$request_xml = $HTTP_RAW_POST_DATA;
$response = xmlrpc_server_call_method($xmlrpc_server, $request_xml, '');
print $response;
xmlrpc_server_destroy($xmlrpc_server);
?>
