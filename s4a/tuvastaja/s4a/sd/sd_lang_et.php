<?php
/* Copyright (C) 2010, Cybernetica AS, http://www.cybernetica.eu/ */

// No direct access

/* NOTE: 
   When making updates in code it is essential that this file remains in UTF-8 w/o BOM encoding 
*/

defined('SD_ADM') or die('Restricted access');

// APPLICATION

define( 'SEQURITY_DETECTOR_MODULE_HEADER', "Tuvastaja haldusliides"); // Sequrity Detector Admin Interface
define( 'SEQURITY_DETECTOR_MODULE_DESCRIPTION', "Turvarikete tuvastaja haldusliides");
define( 'UI_AJAX_PROCESSING_REQUEST', "Päring teostamisel..." );  // Loading...
define( 'UI_AJAX_INVALID_PARAMETERS', "Vigane päring!" );
define( 'UI_MSG_REQUEST_COULD_NOT_BE_PROCESSED', "Päringu sooritamine ebaõnnestus!" );
define( 'UI_LBL_ERROR', "Viga!" );
define( 'UI_LBL_WARNING', "Hoiatus!" );
define( 'UI_SD_SYSTEM_UNKNOWN_USER', "Kasutaja ei ole sisse logitud!" ); // Window title message on non-SSL connection

// - System

define( 'UI_SD_LBL_ID', "Süsteemi tunnusandmed" );
define( 'UI_SD_LBL_ID_SHORTNAME', "Lühinimi" );
define( 'UI_SD_LBL_ID_LONGNAME', "Täisnimi/kirjeldus" );
define( 'UI_SD_LBL_ID_ORGANISATION', "Organisatsioon" );

// - System Tabs Status & Graphs
define( 'UI_SD_LBL_TAB_STATUS', "Süsteemi olek" );
define( 'UI_SD_BTN_REFRESH_STATUS', "Värskenda" );
define( 'UI_SD_BTN_REFRESH_STATUS_TOOLTIP', "Värskenda süsteemi oleku vaadet" );
define( 'UI_SD_BTN_TRY_UPDATE', "Uuenda" );
define( 'UI_SD_BTN_TRY_UPDATE_TOOLTIP', "Kontrolli, kas uuendusi on saadaval" );
define( 'UI_SD_LBL_TAB_GRAPHS', "Süsteemi jõudlus" );
define( 'UI_SD_BTN_REFRESH_GRAPHS', "Värskenda" );
define( 'UI_SD_BTN_REFRESH_GRAPHS_TOOLTIP', "Värskenda süsteemi jõudluse vaadet" );
define( 'UI_SD_BTN_REFRESH_GRAPHS_FAILED', "Värskendamine ebaõnnestus, vajuta F5 klahvile." );
define( 'UI_SD_CBO_INTERVAL_DAY', "Päeva ülevaade" );
define( 'UI_SD_CBO_INTERVAL_WEEK', "Nädala ülevaade" );
define( 'UI_SD_CBO_INTERVAL_MONTH', "Kuu ülevaade" );
define( 'UI_SD_CBO_INTERVAL_YEAR', "Aasta ülevaade" );
define( 'UI_SD_LBL_PROCESS_STATUS', "Turvaprotsessi jõudlusinfo" );
define( 'UI_SD_LBL_SYSTEM_STATUS', "Süsteemi jõudlusinfo" );
define( 'UI_SD_LBL_SNORTO', "Snorti logi analüsaatori töötamine" );
define( 'UI_SD_LBL_IPS_RECORDED', "Sündmustega seotud IP-aadresse" );
define( 'UI_SD_LBL_HOSTS_COUNT', "Aktiivseid ja nakatunud arvuteid sisevõrgus" );
define( 'UI_SD_LBL_EVENTS_RECORDED', "Sündmusi" );
define( 'UI_SD_LBL_EVENTS_HOSTS_RATIO', "Sündmuste/aktiivsete arvutite suhe" );
define( 'UI_SD_LBL_MEMORY_USAGE', "Mälukasutus" );
define( 'UI_SD_LBL_MEMORY_FREE', "Vaba mälu" );
define( 'UI_SD_LBL_CPU_USAGE', "Protsessorikasutus" );
define( 'UI_SD_LBL_DISK_USAGE', "Kettakasutus" );
define( 'UI_SD_LBL_INTERFACE_BGE0', "Liides 0" );
define( 'UI_SD_LBL_INTERFACE_BGE1', "Liides 1" );
define( 'UI_SD_LBL_INTERFACE_BGE2', "Liides 2" );

// - System Tab History Daily
define( 'UI_SD_LBL_TAB_HISTORY_DAILY', "Turvarikete päevane ajalugu" );
define( 'UI_SD_BTN_PREVDAY', "Eelmine päev" );
define( 'UI_SD_BTN_PREVDAY_TOOLTIP', "Eelmine päev" );
define( 'UI_SD_BTN_NEXTDAY', "Järgmine päev" );
define( 'UI_SD_BTN_NEXTDAY_TOOLTIP', "Järgmine päev" );
define( 'UI_SD_NO_SNORT_REPORT_AVAILABLE', "Valitud päeva SNORTi raport puudub" );

// - System Tab History Weekly
define( 'UI_SD_LBL_TAB_HISTORY_WEEKLY', "Turvarikete nädalane ajalugu" );

// - System Tab Log
define( 'UI_SD_LBL_TAB_LOGS', "Süsteemne logi" );
define( 'UI_SD_BTN_PREV', "Eelmine" );
define( 'UI_SD_BTN_PREV_TOOLTIP', "Eelmine" );
define( 'UI_SD_BTN_NEXT', "Järgmine" );
define( 'UI_SD_BTN_NEXT_TOOLTIP', "Järgmine" );
define( 'UI_SD_NO_LOG_AVAILABLE', "Logi puudub" );
define(	'UI_SD_LOG_NR_LINES', "Ridu:" );
define(	'UI_SD_LOG_NAME', "Logi:" );
define( 'UI_SD_CBO_LOGS_UPDATER', "Analüsaatori logi");
define( 'UI_SD_CBO_LOGS_ALERTS', "Snorti logi");


// - System Tab Configuration
define( 'UI_SD_LBL_TAB_CONFIGURATION', "Konfiguratsioon" );
define( 'UI_SD_BTN_NEWKEY', "Uuenda võti" );
define( 'UI_SD_BTN_NEWKEY_TOOLTIP', "Võtme uuendamine nõuab ..." ); // TODO: siit on midagi puudu
define( 'UI_SD_BTN_BACKUP', "Salvesta varukoopia" );
define( 'UI_SD_BTN_BACKUP_TOOLTIP', "Tuvastaja varundatud konfiguratsioon" );
define( 'UI_SD_NO_CONF_FILE_AVAILABLE', "Konfiguratsioonifail puudub" );
define( 'UI_SD_LBL_CONF_FIELD_PARAM', "Parameeter" );
define( 'UI_SD_LBL_CONF_FIELD_VALUE', "Väärtus" );

define( 'UI_SD_SYSCONF_MUST', "Keskne konfiguratsioon" );
define( 'UI_SD_SYSCONF_CONF', "Lokaalne konfiguratsioon" );
define( 'UI_SD_SYSCONF_OPTIONAL', "Valikuline konfiguratsioon" );

define( 'UI_SD_LBL_CERT_UPLOAD_TITLE', "Võtme uuendamine" );
define( 'UI_SD_LBL_CERT_LABEL_CA', "CA sertifikaadi fail" );
define( 'UI_SD_LBL_CERT_LABEL_CERT', "Tuvastaja sertifikaadi fail" );
define( 'UI_SD_LBL_CERT_LABEL_KEY', "Tuvastaja võtmefail" );
define( 'UI_SD_LBL_CERT_UPLOAD_BTN_SAVE', "Uuenda" );
define( 'UI_SD_LBL_CERT_UPLOAD_BTN_CANCEL', "Loobu" );
define( 'UI_SD_LBL_CERTS_UPLOAD_OK', "Võti uuendatud" );
define( 'UI_SD_MSG_CERTS_UPLOAD_SUCCESSFUL', "Sertifikaadid salvestatud" );
define( 'UI_SD_MSG_CERTS_UPLOAD_FAILED', "Salvestamine ebaõnnestus" );

// general
define( 'UI_SD_STATUS_LABEL_UPDATED', "Viimasest uuendamisest on möödunud" );
define( 'UI_SD_LBL_DAYS', "ööpäeva" );
define( 'UI_SD_LBL_HOURS', "tundi" );
define( 'UI_SD_LBL_MINUTES', "minutit" );
define( 'UI_SD_LBL_SECONDS', "sekundit" );
define( 'UI_SD_STATUS_LABEL_SYSTEM', "Infovahetus keskusega" ); // Tuvastaja
define( 'UI_SD_MSG_SYSTEM_CRITICAL', "PROBLEEM: Kontaktist keskserveriga on möödunud enam kui 24 tundi!" );
define( 'UI_SD_MSG_SYSTEM_OK', "OK" );
define( 'UI_SD_MSG_SYSTEM_WARNING', "HOIATUS: Kontaktist keskserveriga on möödunud enam kui 6 tundi!" );
define( 'UI_SD_MSG_SYSTEM_UNKNOWN', "(tundmatu): Teave puudub - tuvastajal pole õnnestunud keskserveriga ühenduda või sellelt vastust saada" );
define( 'UI_SD_STATUS_LABEL_CERT', "Sertifikaat" );
define( 'UI_SD_MSG_CERT_CRITICAL', "Sertifikaate ei leitud või need ei kehti enam" );
define( 'UI_SD_MSG_CERT_OK', "Sertifikaat kehtib" );
define( 'UI_SD_MSG_CERT_WARNING', "Sertifikaat kaotab kehtivuse 20 päeva jooksul" );
define( 'UI_SD_STATUS_LABEL_ROOT', "Ruumi baassüsteemile" );
define( 'UI_SD_STATUS_LABEL_DATA', "Ruumi logidele" );
define( 'UI_SD_STATUS_LABEL_RATIO', "Avastatud turvarikkeid" );
define( 'UI_SD_MSG_RATIO_CRITICAL', "Turvarikkeid on rohkem kui 10% arvutitel" );
define( 'UI_SD_MSG_RATIO_OK', "Ühe tunni keskmiselt on turvarikkeid alla 1% arvutitel" );
define( 'UI_SD_MSG_RATIO_WARNING', "Ühe tunni keskmiselt on turvarikkeid kuni 10% arvutitel" );
define( 'UI_SD_STATUS_LABEL_SNORT', "Snorti deemoni töötamine" );
define( 'UI_SD_STATUS_LABEL_SIGS', "Signatuuride uuendamise aeg" );
define( 'UI_SD_STATUS_LABEL_CONF', "Konfiguratsiooni loomise aeg" );
define( 'UI_SD_STATUS_LABEL_CPU', "Protsessori(te) koormus" );
define( 'UI_SD_STATUS_LABEL_SIGCOUNTER', "Info kogumine turvarikete kohta" );
define( 'UI_SD_STATUS_LABEL_IPCOUNTER', "Info kogumine aktiivsete arvutite kohta" );
define( 'UI_SD_STATUS_LABEL_DNS', "DNSi töö" );
define( 'UI_SD_STATUS_LABEL_NTP', "Kella õigsuse kontroll" );

define('UI_SD_STATUS_LABEL_HEAD_CENTRE', "Liidestumine keskusega");
define('UI_SD_STATUS_LABEL_HEAD_SNORT', "Põhiprotsessi toimimine");
define('UI_SD_STATUS_LABEL_HEAD_LOCAL', "Masina seisund");

# Those tables translate variables to human-readable text
# MUST - from certificate + sw version
# CONF - must be configured to function
# OPTIONAL - anything you can decide for yourself

$VARIABLES_MUST=array(
	'Shortname' => 'Tuvastaja ID sertifikaadist',
	'Organisation' => 'Tuvastaja organisatsioon sertifikaadist',
	'Fullname' => 'Tuvastaja nimi sertifikaadist',
	'Centralserver' => 'Keskserveri aadress sertifikaadist',
	'Software_Version' => 'Tuvastaja tarkvara versioon'
);

$VARIABLES_CONF=array(
	'IFACE' => 'Tuvastaja haldusliides',
	'Trunkifaces' => 'Andmete kogumise liidesed',
	'IP_address' => 'Tuvastaja IP-aadress',
	'Subnet_mask' => 'Võrgumask',
	'Default_Gateway' => 'Vaikemarsruuter',
	'Hostname' => 'Tuvastaja serveri DNSi nimi',
	'Domain' => 'Tuvastaja domeeni nimi',
	'NameServers' => 'Nimeserver',
	'NTP_server' => 'Ajaserver',
	'Localnets' => 'Lokaalsete aadresside klassid'
);

$VARIABLES_OPTIONAL=array(
	'Admin_Email' => 'Administraatori meiliaadress',
	'SMTP' => 'Tuvastaja meilivahendaja aadress',
	'Syslogserver' => 'Väline süsteemse logi server',
	'SNMP_server' => 'Välise seiresüsteemi aadress',
	'Ro_community' => 'Välise seiresüsteemi community nimi (SNMP)',
	'Second_central' => 'Sekundaarne keskserver'
);

