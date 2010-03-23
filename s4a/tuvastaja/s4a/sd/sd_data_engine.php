<?php
/* Copyright (C) 2010, Cybernetica AS, http://www.cybernetica.eu/ */

// Set vital constants

define ('SD_ADM', true);
define ('SD_CONFIG_FILE', 'sd_config.php');

preg_match( '/^.+\//', $_SERVER['SCRIPT_FILENAME'], $curpath);
require_once( $curpath[0] . SD_CONFIG_FILE );
require_once( $curpath[0] . $CONFIG['system_lang_file'] );
require_once( $curpath[0] . $CONFIG['grapher_clss_file'] );

$task = '';
if ( isset($_POST['task'])) {
	$task = $_POST['task'];   // Task supplied via post method
}

switch($task)
{
	case "sysstatus":     // System Status View
		sysStatus();
		break;
	case "sysgraphs":     // System Graphs View
		$span = '';
		if (isset($_POST['span'])) {
			$span = $_POST['span'];   // Should be provided by interface
		}
		sysGraphs( $span );
		break;
	case "sysconf":     // System Config List
		sysConfig();
		break;
	default:
		echo "{failure:true,errtxt:'Unrecognized task [" . $task . "]'}";  // Simple 1-dim JSON array to tell Ext the request failed.
		break;
}

function sysStatus() 
{
	global $CONFIG, $curpath;
	
	// 0=error (red), 1=ok (green), 2=WARNING (yellow), 3=unknown (blue)
	$state_icon = array('iconError','iconOK','iconAlert','iconInfo');
	

	$allout = runSehllCMD("/tuvastaja/nrpe/runall.sh");

	if (preg_match ( '/(\d+)? seconds old/', $allout[10], $matches)) {
		$last_updated_secs = $matches[0];
		$state_update_value = getStatusUpdate($last_updated_secs, intval($CONFIG['system_update_warning_seconds']), intval($CONFIG['system_update_alert_seconds']));
		$last_update_done = getLastUpdateDone($last_updated_secs);
	} 
	else {
		// State could not be calculated = UNKNOWN
		$state_update_value = 3;
	}
	
	$state_system_msg = array(UI_SD_MSG_SYSTEM_CRITICAL, UI_SD_MSG_SYSTEM_OK, UI_SD_MSG_SYSTEM_WARNING, UI_SD_MSG_SYSTEM_UNKNOWN);
	$state_system_value = $state_update_value;

	$state_cert_msg = array(UI_SD_MSG_CERT_CRITICAL, UI_SD_MSG_CERT_OK, UI_SD_MSG_CERT_WARNING);
	$state_cert_nrpe = $allout[0];
	$state_cert_value = getStateValue($state_cert_nrpe);
	
	$state_root_nrpe = $allout[1];
	$state_root_value = getStateValue($state_root_nrpe);

	$state_data_nrpe = $allout[2];
	$state_data_value = getStateValue($state_data_nrpe);
	
	$state_ratio_msg = array(UI_SD_MSG_RATIO_CRITICAL, UI_SD_MSG_RATIO_OK, UI_SD_MSG_RATIO_WARNING);
	$state_ratio_nrpe = $allout[3];
	$state_ratio_value = getStateValue($state_ratio_nrpe);
	
	$state_snort_nrpe = $allout[4];
	$state_snort_value = getStateValue($state_snort_nrpe);
	
	$state_cpu_nrpe = $allout[5];
	$state_cpu_value = getStateValue($state_cpu_nrpe);
	
	$state_sigcounter_nrpe = $allout[6];
	$state_sigcounter_value = getStateValue($state_sigcounter_nrpe);
	
	$state_ipcounter_nrpe = $allout[7];
	$state_ipcounter_value = getStateValue($state_ipcounter_nrpe);
	
	$state_dns_nrpe = $allout[8];
	$state_dns_value = getStateValue($state_dns_nrpe);
	
	$state_ntp_nrpe = $allout[9];
	$state_ntp_value = getStateValue($state_ntp_nrpe);

	$state_conf_str = "";
	$state_conf_value = 3;
	if (file_exists($CONFIG['system_backuppath'] . $CONFIG['system_backupfile'])) {
		$state_conf_str = date ("Y-m-d H:i:s", filemtime($CONFIG['system_backuppath'] . $CONFIG['system_backupfile']));
		$state_conf_value = 1;
	} 

	$state_sigs_str = "";
	$state_sigs_value = 3;
	if (file_exists($CONFIG['system_snort_map_file'])) {
		$state_sigs_str = date ("Y-m-d H:i:s", filemtime($CONFIG['system_snort_map_file']));
		$state_sigs_value = 1;
	} 
	
	
	$syss  = '<div style="display: block; float: left; background-color: #fff; width: 100%; overflow: hidden;">';
	$syss .=  '<table cellspacing="4" cellpadding="0" border="0" >';
	$syss .= '<thead><tr><th width="30%"></th><th width="70%"></th></tr></thead>';
	$syss .= '<tbody>';
	$syss .= '<tr><th class="tbl-list-head" colspan="2">'. UI_SD_STATUS_LABEL_HEAD_CENTRE .'</th></tr>';
	$syss .= '<tr><td class="' . $state_icon[$state_system_value] . '">' . UI_SD_STATUS_LABEL_SYSTEM . '</td>';
	$syss .= '<td><b>' . $state_system_msg[$state_system_value] . '</b></td></tr>';
	$syss .= '<tr><td class="' . $state_icon[$state_update_value] . '">' . UI_SD_STATUS_LABEL_UPDATED . '</td>';
	$syss .= '<td>' . $last_update_done . '</td></tr>';
	$syss .= '<tr><td class="' . $state_icon[$state_cert_value] . '">' . UI_SD_STATUS_LABEL_CERT . '</td>';
	$syss .= '<td>' . $state_cert_msg[$state_cert_value] . '</td></tr>';
	$syss .= '<tr><td class="' . $state_icon[$state_dns_value] . '">' . UI_SD_STATUS_LABEL_DNS . '</td>';
	$syss .= '<td>' . $state_dns_nrpe . '</td></tr>';
	$syss .= '<tr><td class="' . $state_icon[$state_ntp_value] . '">' . UI_SD_STATUS_LABEL_NTP . '</td>';
	$syss .= '<td>' . $state_ntp_nrpe . '</td></tr>';
	$syss .= '</tbody>';

	$syss .= '<tbody>';
	$syss .= '<tr><th class="tbl-list-head" colspan="2">'. UI_SD_STATUS_LABEL_HEAD_SNORT .'</th></tr>';
	$syss .= '<tr><td class="' . $state_icon[$state_sigs_value] . '">' . UI_SD_STATUS_LABEL_SIGS . '</td>';
	$syss .= '<td>' . $state_sigs_str . '</td></tr>';
	$syss .= '<tr><td class="' . $state_icon[$state_snort_value] . '">' . UI_SD_STATUS_LABEL_SNORT . '</td>';
	$syss .= '<td>' . $state_snort_nrpe . '</td></tr>';
	$syss .= '<tr><td class="' . $state_icon[$state_sigcounter_value] . '">' . UI_SD_STATUS_LABEL_SIGCOUNTER . '</td>';
	$syss .= '<td>' . $state_sigcounter_nrpe . '</td></tr>';
	$syss .= '<tr><td class="' . $state_icon[$state_ipcounter_value] . '">' . UI_SD_STATUS_LABEL_IPCOUNTER . '</td>';
	$syss .= '<td>' . $state_ipcounter_nrpe . '</td></tr>';
	$syss .= '<tr><td class="' . $state_icon[$state_ratio_value] . '">' . UI_SD_STATUS_LABEL_RATIO . '</td>';
	$syss .= '<td>' . $state_ratio_msg[$state_ratio_value] . '</td></tr>';
	$syss .= '</tbody>';

	$syss .= '<tbody>';
	$syss .= '<tr><th class="tbl-list-head" colspan="2">'. UI_SD_STATUS_LABEL_HEAD_LOCAL .'</th></tr>';
	$syss .= '<tr><td class="' . $state_icon[$state_conf_value] . '">' . UI_SD_STATUS_LABEL_CONF . '</td>';
	$syss .= '<td>' . $state_conf_str . '</td></tr>';
	$syss .= '<tr><td class="' . $state_icon[$state_cpu_value] . '">' . UI_SD_STATUS_LABEL_CPU . '</td>';
	$syss .= '<td>' . $state_cpu_nrpe . '</td></tr>';
	$syss .= '<tr><td class="' . $state_icon[$state_root_value] . '">' . UI_SD_STATUS_LABEL_ROOT . '</td>';
	$syss .= '<td>' . $state_root_nrpe . '</td></tr>';
	$syss .= '<tr><td class="' . $state_icon[$state_data_value] . '">' . UI_SD_STATUS_LABEL_DATA . '</td>';
	$syss .= '<td>' . $state_data_nrpe . '</td></tr>';

	$syss .= '</tbody>';
	
	$syss .= '</table>';
	$syss .= '</div>';
	echo $syss;
}


function sysGraphs($span) 
{
	global $CONFIG, $curpath;
	global $alltargetdefs, $allrangedefs, $commondefs;
	
	$targets = array(
		"hostcount" => 'Active & Bad Host Count',
		"seventscount" => 'Events Recorded',
		"memory" => 'Memory Usage',
		"if2" => 'Interface bge0',
		"if3" => 'Interface bge1',
		"if4" => 'Interface bge2',
		"cpu" => 'CPU Utilization',
		"disk" => 'Disk Partition Usage',
		"snorto" => 'Snortomatic runtime'
	);

	foreach ($targets as $targetkey => $targetvalue) {
		if (isset($alltargetdefs[$targetkey]) && isset($allrangedefs[$span])) {
			$targettmp = $alltargetdefs[$targetkey];
			$partfilename = "server.".$targetkey."-".$span.".png";
			$filename = $CONFIG['system_graph_path'] . $partfilename;
			$rrdtool = new RRDTool();
			$rrdtool->graph($filename,$commondefs,$allrangedefs[$span],$targettmp, "server");
		}
	}
	
	$cachebuster = '?' . time(); // cachebuster string makes image names unique to ensure loading

	$div_end = '</div>';
	$div_display = '<div style="display: block; float: left; margin: 16px 16px 4px 4px;">';
	$div_imagetitle = '<div class="imagetitle" style="font-weight: bold; padding: 3px; background-color: #eee;">';
	$div_grouptitle = '<div class="grouptitle" style="width: 100%; font-weight: bold; font-size: 1.6em; padding: 8px 3px 8px 3px;">';
	$div_block = '<div style="clear:left;">';
	$div_block_line = '<div style="clear:left; border-top: 2px solid #ccc; margin-top: 16px;">';

	$syss = '<div style="overflow:hidden;">'; 
	$syss = $syss . $div_block;
	$syss = $syss . $div_grouptitle . UI_SD_LBL_PROCESS_STATUS . $div_end;
	$syss = $syss . $div_display . $div_imagetitle . UI_SD_LBL_HOSTS_COUNT . $div_end;
 	$syss = $syss . '<img src="' . $CONFIG['system_graph_path_url'] . 'server.hostcount-' . $span . '.png' . $cachebuster . '"/>' . $div_end;
	$syss = $syss . $div_display . $div_imagetitle . UI_SD_LBL_EVENTS_RECORDED . $div_end;
 	$syss = $syss . '<img src="' . $CONFIG['system_graph_path_url'] . 'server.seventscount-' . $span . '.png' . $cachebuster . '"/>' . $div_end;
	$syss = $syss . $div_display . $div_imagetitle . UI_SD_LBL_SNORTO . $div_end;
	$syss = $syss . '<img src="' . $CONFIG['system_graph_path_url'] . 'server.snorto-' . $span . '.png' . $cachebuster . '"/>' . $div_end;
	$syss = $syss . $div_end;

	$syss = $syss . $div_block_line;	
	$syss = $syss . $div_grouptitle . UI_SD_LBL_SYSTEM_STATUS . $div_end;
	$syss = $syss . $div_display . $div_imagetitle . UI_SD_LBL_MEMORY_USAGE . $div_end;
 	$syss = $syss . '<img src="' . $CONFIG['system_graph_path_url'] . 'server.memory-' . $span . '.png' . $cachebuster . '"/>' . $div_end;
	$syss = $syss . $div_display . $div_imagetitle . UI_SD_LBL_CPU_USAGE . $div_end;
 	$syss = $syss . '<img src="' . $CONFIG['system_graph_path_url'] . 'server.cpu-' . $span . '.png' . $cachebuster . '"/>' . $div_end;
	$syss = $syss . $div_display . $div_imagetitle . UI_SD_LBL_DISK_USAGE . $div_end;
 	$syss = $syss . '<img src="' . $CONFIG['system_graph_path_url'] . 'server.disk-' . $span . '.png' . $cachebuster . '"/>' . $div_end;
	$syss = $syss . $div_end;

	$syss = $syss . $div_block;
	$syss = $syss . $div_display . $div_imagetitle . UI_SD_LBL_INTERFACE_BGE0 . $div_end;
 	$syss = $syss . '<img src="' . $CONFIG['system_graph_path_url'] . 'server.if2-' . $span . '.png' . $cachebuster . '"/>' . $div_end;
	$syss = $syss . $div_display . $div_imagetitle . UI_SD_LBL_INTERFACE_BGE1 . $div_end;
 	$syss = $syss . '<img src="' . $CONFIG['system_graph_path_url'] . 'server.if3-' . $span . '.png' . $cachebuster . '"/>' . $div_end;
	$syss = $syss . $div_display . $div_imagetitle . UI_SD_LBL_INTERFACE_BGE2 . $div_end;
 	$syss = $syss . '<img src="' . $CONFIG['system_graph_path_url'] . 'server.if4-' . $span . '.png' . $cachebuster . '"/>' . $div_end;
	$syss = $syss . $div_end;
	
	$syss = $syss . $div_block . '<p style="margin: 16px 16px 4px 4px;" id="timestamp">' . date('Y-m-d H:i:s') . '</p>' . $div_end;
	$syss = $syss . $div_end;
	
	$systemstatus = $syss;
	echo $systemstatus;
}

function runSehllCMD($cmd)
{
	$output = array();
	$response = exec( $cmd, $output);
	for($i = 0; $i < count($output); $i++) {
		$splitpos = strpos( $output[$i], '|' );
		if ( $splitpos !== false ) {
			$output[$i] = substr($output[$i], 0, $splitpos );
		}
	}
	return $output;
}


function getNrpeResult($cmd)
{
	$result = '';
	$response = exec( $cmd );
	$splitpos = strpos( $response, '|' );
	if ( $splitpos !== false )
	{
		$result = substr( $response, 0, $splitpos );
	}
	else
	{
		$result = $response;
	}
	return $result;
}


function getStateValue( $msg ) {
	if (stripos ($msg, 'CRITICAL') !== false) {
		return 0;
	}

	if (stripos ($msg, 'WARNING') !== false) {
		return 2;
	}

	if (stripos ($msg, 'OK') !== false) {
		return 1;
	}
	
	// status = unknown
	return 3;
}


function getLastUpdate()
{
	$cmd = '/bin/check_nrpe -H 127.0.0.1 -c check_updater';
	$response = shell_exec( $cmd );
	preg_match ( '/(\d+)? seconds/', $response, $matches );
	return intval($matches[0]);
}


function getLastUpdateDone($seconds)
{
	$days = intval($seconds / (3600*24));
	$hours = intval(($seconds - ($days * 3600 * 24)) / 3600);
	$mins = intval(($seconds - ($days * 3600 * 24) - ($hours * 3600)) / 60);
	$secs = intval(($seconds - ($days * 3600 * 24) - ($hours * 3600) - ($mins * 60)));
	return $days . ' ' . UI_SD_LBL_DAYS . ', ' . $hours . ' ' . UI_SD_LBL_HOURS . ', ' . $mins . ' ' . UI_SD_LBL_MINUTES . ', ' . $secs . ' ' . UI_SD_LBL_SECONDS; // [' . $seconds . ']';
}


function getStatusUpdate($secs_from_update, $warn_limit, $alert_limit)
{
	if ($secs_from_update > $warn_limit)
	{
		if ($secs_from_update > $alert_limit)
		{
			$status = 0;	
		}
		else
		{
			$status = 2;
		}
	}
	else
	{
		$status = 1;
	}
	return $status;
}


function sysConfig() 
{
	global $SYSCONFIG;
	global $VARIABLES_MUST;
	global $VARIABLES_CONF;
	global $VARIABLES_OPTIONAL;
	
	$valuetablerows = '';

	$valuetablerows .= '<tbody>';
	$valuetablerows .= '<tr><th class="tbl-list-head" colspan="2">'. UI_SD_SYSCONF_MUST .'</th></tr>';
	foreach ($VARIABLES_MUST as $key => $value) {
		if (isset($SYSCONFIG[$key])) {
			$valuetablerows .= '<tr><td class="tbl-list-row-left">' . $value . '</td>';
			$valuetablerows .= '<td class="tbl-list-row">' . $SYSCONFIG[$key] . '</td></tr>';
		}
	}
	$valuetablerows .= '</tbody>';

	$valuetablerows .= '<tbody>';
	$valuetablerows .= '<tr><th class="tbl-list-head" colspan="2">'. UI_SD_SYSCONF_CONF .'</th></tr>';
	foreach ($VARIABLES_CONF as $key => $value) {
		if (isset($SYSCONFIG[$key])) {
			$valuetablerows .= '<tr><td class="tbl-list-row-left">' . $value . '</td>';
			$valuetablerows .= '<td class="tbl-list-row">' . $SYSCONFIG[$key] . '</td></tr>';
		}
	}
	$valuetablerows .= '</tbody>';

	$valuetablerows .= '<tbody>';
	$valuetablerows .= '<tr><th class="tbl-list-head" colspan="2">'. UI_SD_SYSCONF_OPTIONAL .'</th></tr>';
	foreach ($VARIABLES_OPTIONAL as $key => $value) {
		if (isset($SYSCONFIG[$key])) {
			$valuetablerows .= '<tr><td class="tbl-list-row-left">' . $value . '</td>';
			$valuetablerows .= '<td class="tbl-list-row">' . $SYSCONFIG[$key] . '</td></tr>';
		}
	}
	$valuetablerows .= '</tbody>';


	if ($valuetablerows == '') {
		$valuetablerows = UI_SD_NO_CONF_FILE_AVAILABLE;
	} 
	else {
		$valuetable  = '<table class="tbl-list" width="100%" cellspacing="0" cellpadding="0" border="0">'
		             . '<thead><tr><th width="25%"></th><th width="75%"></th>'
		             . '</tr></thead>' . $valuetablerows . '</table>';
	}
	echo $valuetable;
}

