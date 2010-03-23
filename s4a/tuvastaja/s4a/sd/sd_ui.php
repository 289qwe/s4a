<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<?php
/* Copyright (C) 2010, Cybernetica AS, http://www.cybernetica.eu/ */

/* Sequrity Risk Detector User Interface */

/* NOTE: 
   When making updates in code it is essential that this file remains in UTF-8 w/o BOM encoding 
*/

define ('SD_ADM', true);   // Other scripts respond with 'Restrictes access' if this is not set
define ('SD_CONFIG_FILE', 'sd_config.php');

// Get current script path
preg_match( '/^.+\//', $_SERVER['SCRIPT_FILENAME'], $curpath);
// Load configuration settings
require_once( $curpath[0] . SD_CONFIG_FILE );
// Load language - based on configuration settings
require_once( $curpath[0] . $CONFIG['system_lang_file'] );

// Get user credentials for authenticated user
if ( array_key_exists('HTTPS', $_SERVER) && 
     array_key_exists('SSL_CLIENT_S_DN_CN', $_SERVER) && 
     $_SERVER['HTTPS'] &&
     $_SERVER['SSL_CLIENT_S_DN_CN'] )
{
	$ssl_user = explode(',',$_SERVER['SSL_CLIENT_S_DN_CN']);
	$user['m_serial'] =  $_SERVER['SSL_CLIENT_M_SERIAL'];
	$user['fname'] =  $ssl_user[1];
	$user['sname'] =  $ssl_user[0];
	$user['id'] =  $ssl_user[2];
	// If all fields contain data - set authenticated to true
	$user['authenticated'] =  $user['m_serial'] && $user['fname'] && $user['sname'] && $user['id'];
} else {
	$user['authenticated'] = false;
}

?>

<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<meta name="title" content="<?php  echo SEQURITY_DETECTOR_MODULE_HEADER; ?>" />
		<meta name="description" content="<?php  echo SEQURITY_DETECTOR_MODULE_DESCRIPTION; ?>" />
	
		<title><?php echo SEQURITY_DETECTOR_MODULE_HEADER; ?></title>
		<!-- ** CSS ** -->
		<!-- base library -->
		<link rel="stylesheet" type="text/css" href="<?php echo $CONFIG['system_ext_path_url'] ?>resources/css/ext-all.css" />
		<!-- overrides to base library -->
		<link rel="stylesheet" type="text/css" href="sd_styles.css" />
		
		<!-- ** Javascript ** -->
		<!-- ExtJS library: base/adapter -->
		<script type="text/javascript" src="<?php echo $CONFIG['system_ext_path_url'] ?>adapter/ext/ext-base.js"></script>
		<!-- ExtJS library: all widgets -->
		<!-- script type="text/javascript" src="<?php echo $CONFIG['system_ext_path_url'] ?>ext-all-debug.js"></script -->
		<script type="text/javascript" src="<?php echo $CONFIG['system_ext_path_url'] ?>ext-all.js"></script>
		
		<!-- overrides to base library -->
		
		<!-- extensions -->
		
		<!-- page specific -->
		<script type="text/javascript">
			/* Configuration settings */
			Ext.BLANK_IMAGE_URL = '<?php echo $CONFIG['system_ext_path_url'] ?>resources/images/default/s.gif';

			var SD_GET_DATA_URL = "<?php echo $CONFIG['system_getdata_url'] ?>";

			<?php 
				if ($user['authenticated']) 
				{
					echo 'var CS_AUTH_CLASS = "authenticated";' . "\n";
					echo '			var SD_USER = "' . $user['fname'] . ', ' . $user['sname'] . '";' . "\n";
				} else {
					echo 'var CS_AUTH_CLASS = "unknown";' . "\n";
					echo '			var SD_USER = "' . UI_SD_SYSTEM_UNKNOWN_USER . '";' . "\n";
				}
			?>

			/* Get language strings from language file */
			
			/* - General */
			var LBL_DETECTOR_TITLE = "<?php echo SEQURITY_DETECTOR_MODULE_HEADER ?>";
			var LBL_SYS_PROCESSING_REQUEST = "<?php echo UI_AJAX_PROCESSING_REQUEST ?>";
			var MSG_REQUEST_COULD_NOT_BE_PROCESSED = "<?php echo UI_MSG_REQUEST_COULD_NOT_BE_PROCESSED ?>";
			var LBL_WARNING = "<?php echo UI_LBL_WARNING ?>";
			var LBL_ERROR = "<?php echo UI_LBL_ERROR ?>";
			var FRAME_RELOAD_INTERVAL = <?php echo $CONFIG['UI_FRAME_RELOAD_INTERVAL'] ?>;

			/* - System overview */
			var SYSTEM_ID = "<?php echo $SYSCONFIG['Shortname'] ?>";
			var SYSTEM_NAME = "<?php echo $SYSCONFIG['Fullname'] ?>"; 
			var SYSTEM_ORG = "<?php echo $SYSCONFIG['Organisation'] ?>"; 
			var LBL_SYSTEM_ID = "<?php echo UI_SD_LBL_ID ?>";
			var LBL_SYSTEM_ID_SHORTNAME = "<?php echo UI_SD_LBL_ID_SHORTNAME ?>";
			var LBL_SYSTEM_ID_LONGNAME = "<?php echo UI_SD_LBL_ID_LONGNAME ?>";
			var LBL_SYSTEM_ID_ORGANISATION = "<?php echo UI_SD_LBL_ID_ORGANISATION ?>"; 

			/* - System Status Tab */			
			var LBL_SD_SYSTEM_STATUS_TAB = "<?php echo UI_SD_LBL_TAB_STATUS ?>";
			var LBL_SD_SYSTEM_STATUS_BTN_REFRESH = "<?php echo UI_SD_BTN_REFRESH_STATUS ?>";
			var MSG_SD_SYSTEM_STATUS_BTN_REFRESH_TOOLTIP = "<?php echo UI_SD_BTN_REFRESH_STATUS_TOOLTIP ?>";
			//var LBL_SD_SYSTEM_STATUS_BTN_TRY_UPDATE = "<?php echo UI_SD_BTN_TRY_UPDATE ?>";
			//var MSG_SD_SYSTEM_STATUS_BTN_TRY_UPDATE_TOOLTIP = "<?php echo UI_SD_BTN_TRY_UPDATE_TOOLTIP ?>";

			/* - System Graphs Tab */			
			var LBL_SD_SYSTEM_GRAPHS_TAB = "<?php echo UI_SD_LBL_TAB_GRAPHS ?>";
			var LBL_SD_SYSTEM_GRAPHS_BTN_REFRESH = "<?php echo UI_SD_BTN_REFRESH_GRAPHS ?>";
			var MSG_SD_SYSTEM_GRAPHS_BTN_REFRESH_TOOLTIP = "<?php echo UI_SD_BTN_REFRESH_GRAPHS_TOOLTIP ?>";
			var MSG_SD_SYSTEM_GRAPHS_BTN_REFRESH_FAILED = "<?php echo UI_SD_BTN_REFRESH_GRAPHS_FAILED ?>";
			var LBL_SD_SYSTEM_GRAPHS_CBO_INTERVAL_DAY = "<?php echo UI_SD_CBO_INTERVAL_DAY ?>";
			var LBL_SD_SYSTEM_GRAPHS_CBO_INTERVAL_WEEK = "<?php echo UI_SD_CBO_INTERVAL_WEEK ?>";
			var LBL_SD_SYSTEM_GRAPHS_CBO_INTERVAL_MONTH = "<?php echo UI_SD_CBO_INTERVAL_MONTH ?>";
			var LBL_SD_SYSTEM_GRAPHS_CBO_INTERVAL_YEAR = "<?php echo UI_SD_CBO_INTERVAL_YEAR ?>";
			var SD_SYSTEM_GRAPHS_CBO_DEFAULT_VALUE = 'day';

			/* - System History Daily Tab */
			var LBL_SD_SYSTEM_HISTORY_DAILY_TAB = "<?php echo UI_SD_LBL_TAB_HISTORY_DAILY ?>";
			var LBL_SD_SYSTEM_HISTORY_DAILY_BTN_DAY_PREV = "<?php echo UI_SD_BTN_PREVDAY ?>";
			var MSG_SD_SYSTEM_HISTORY_DAILY_BTN_DAY_PREV_TOOLTIP = "<?php echo UI_SD_BTN_PREVDAY_TOOLTIP ?>";
			var LBL_SD_SYSTEM_HISTORY_DAILY_BTN_DAY_NEXT = "<?php echo UI_SD_BTN_NEXTDAY ?>";
			var MSG_SD_SYSTEM_HISTORY_DAILY_BTN_DAY_NEXT_TOOLTIP = "<?php echo UI_SD_BTN_NEXTDAY_TOOLTIP ?>";
			var SYSTEM_HISTORY_DAILY_URL_PATH = "<?php echo $CONFIG['system_history_daily_url_path'] ?>";
			
			/* - System Logs Tab */
			var LBL_SD_SYSTEM_LOGS_TAB = "<?php echo UI_SD_LBL_TAB_LOGS ?>";
			var LBL_SD_SYSTEM_LOGS_BTN_PREV = "<?php echo UI_SD_BTN_PREV ?>";
			var MSG_SD_SYSTEM_LOGS_BTN_PREV_TOOLTIP = "<?php echo UI_SD_BTN_PREV_TOOLTIP ?>";
			var LBL_SD_SYSTEM_LOGS_BTN_NEXT = "<?php echo UI_SD_BTN_NEXT ?>";
			var MSG_SD_SYSTEM_LOGS_BTN_NEXT_TOOLTIP = "<?php echo UI_SD_BTN_NEXT_TOOLTIP ?>";
			var LBL_SD_SYSTEM_LOGS_NR_LINES = "<?php echo UI_SD_LOG_NR_LINES ?>";
			var LBL_SD_SYSTEM_LOGS_LOG_NAME = "<?php echo UI_SD_LOG_NAME ?>";

			var LBL_SD_SYSTEM_LOGS_CBO_UPDATER = "<?php echo UI_SD_CBO_LOGS_UPDATER ?>";
			var LBL_SD_SYSTEM_LOGS_CBO_ALERTS = "<?php echo UI_SD_CBO_LOGS_ALERTS ?>";
			var SD_SYSTEM_LOGS_CBO_DEFAULT_VALUE = 'updater';

			var SYSTEM_LOGVIEW_URL_PATH = "<?php echo $CONFIG['system_logview_url_path'] ?>";

			/* - System Config Tab */
			var LBL_SD_SYSTEM_CONFIGURATION_TAB = "<?php echo UI_SD_LBL_TAB_CONFIGURATION ?>";
			var LBL_SD_SYSTEM_CONF_BTN_NEWKEY = "<?php echo UI_SD_BTN_NEWKEY ?>";
			var MSG_SD_SYSTEM_CONF_BTN_NEWKEY_TOOLTIP = "<?php echo UI_SD_BTN_NEWKEY_TOOLTIP ?>";
			var LBL_SD_SYSTEM_CONF_BTN_BACKUP = "<?php echo UI_SD_BTN_BACKUP ?>";
			var MSG_SD_SYSTEM_CONF_BTN_BACKUP_TOOLTIP = "<?php echo UI_SD_BTN_BACKUP_TOOLTIP ?>";
			var BACKUP_FILE_URL = "<?php echo $CONFIG['system_backupurl'] . $CONFIG['system_backupfile']  ?>";

			var LBL_SD_CERT_UPLOAD_TITLE = "<?php echo UI_SD_LBL_CERT_UPLOAD_TITLE ?>";
			var LBL_SD_CERT_LABEL_CA = "<?php echo UI_SD_LBL_CERT_LABEL_CA ?>";
			var LBL_SD_CERT_LABEL_CERT = "<?php echo UI_SD_LBL_CERT_LABEL_CERT ?>";
			var LBL_SD_CERT_LABEL_KEY = "<?php echo UI_SD_LBL_CERT_LABEL_KEY ?>";
			var LBL_SD_CERT_UPLOAD_BTN_SAVE = "<?php echo UI_SD_LBL_CERT_UPLOAD_BTN_SAVE ?>";
			var LBL_SD_CERT_UPLOAD_BTN_CANCEL = "<?php echo UI_SD_LBL_CERT_UPLOAD_BTN_CANCEL ?>";
			var LBL_SD_CERTS_UPLOAD_OK = "<?php echo UI_SD_LBL_CERTS_UPLOAD_OK ?>";
			var MSG_SD_CERTS_UPLOAD_SUCCESSFUL = "<?php echo UI_SD_MSG_CERTS_UPLOAD_SUCCESSFUL ?>";
			var MSG_SD_CERTS_UPLOAD_FAILED = "<?php echo UI_SD_MSG_CERTS_UPLOAD_FAILED ?>";
		</script>
		<script type="text/javascript" src="js/sd_main.js"></script>
	</head>
	<body></body>
</html>
