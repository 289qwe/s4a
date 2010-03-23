/* Copyright (C) 2010, Cybernetica AS, http://www.cybernetica.eu/ */
/* Detector Admin Interface */

Ext.onReady(function()
{
	Ext.QuickTips.init();
	Ext.Updater.defaults.indicatorText = LBL_SYS_PROCESSING_REQUEST;
	
	Date.monthNames = [
		'Jan',
		'Veb',
		'Mär',
		'Apr',
		'Mai',
		'Jun',
		'Jul',
		'Aug',
		'Sep',
		'Okt',
		'Nov',
		'Det'
	];
	
	
	Ext.DatePicker.prototype.dayNames = [
			'Pühapäev',
			'Esmaspäev',
			'Teisipäev',
			'Kolmapäev',
			'Neljapäev',
			'Reede',
			'Laupäev'
	];
	
	Ext.DatePicker.prototype.monthNames = [
		'Jaanuar',
		'Veebruar',
		'Märts',
		'Aprill',
		'Mai',
		'Juuni',
		'Juuli',
		'August',
		'September',
		'Oktoober',
		'November',
		'Detsember'
	];
	
	
	Ext.apply(Ext.DatePicker.prototype, {
		todayText : 'Täna',
		okText : ' OK ',
		cancelText : 'Loobu',
		todayTip : '{0} (Vahelöök)',
		minText : 'Kuupäev on lubatud ajavahemikust varasem',
		maxText : 'Kuupäev on lubatud ajavahemikust hilisem',
		//format : 'Y.m.d',
		disabledDaysText : 'Disabled',
		disabledDatesText : 'Disabled',
		nextText : 'Järgmine kuu (Control + Nool paremale)',
		prevText : 'Eelmine kuu (Control + Nool vasakule)',
		monthYearText : 'Vali kuu (Control + Nool üles/alla aasta valikuks)'
		//startDay : 1
	});
	
	Ext.DatePicker.prototype.startDay = 1;
	
	var historylog = -1;
	
	// * END of System Status View */


	/* Application Layout */
	
	var pnlSystemOverview = new Ext.Panel({
//		//autoLoad: { url: SD_GET_DATA_URL, params: 'task=sysstatus', scope: this },
	});
	
	var pnlSystemGraphs = new Ext.Panel({
//		//autoLoad: { url: SD_GET_DATA_URL, params: 'task=sysgraphs&span=' + SD_SYSTEM_GRAPHS_CBO_DEFAULT_VALUE, scope: this }
	});

	var pnlSystemLog = new Ext.Panel({
//		autoLoad: { url: SD_GET_DATA_URL, params: 'task=updaterlog' }
	});
	
	
	var mainLayout = new Ext.Viewport({
		
		// Viewport automatically renders to document.body, spans to browser window 
		// size and manages resizing but does not provide scrolling
		
		id: 'viewport',
		layout: 'fit',
		items: [{
			// container to fill out whole area
			layout: 'anchor',
			title: '<nobr>' + LBL_DETECTOR_TITLE + '</nobr>', // no linebreaks allowed
//			// NOTE: SSL state and logged in user name display in window title
			frame: true,
			items:[{
				
				/* System Details */
				
				// nested container to create two vertical areas
				// - upper is automatically sized to what the content requires having no anchor value set
				// - lower, having anchor set to 100% -95, fills out the available space 
				border: false,
				items: [{
					xtype: 'form',
					title: LBL_SYSTEM_ID,
					collapsible: true,
					//labelWidth: 75, // label settings here cascade unless overridden
					frame:true,
					width: '100%',
					//renderTo: document.body,
					hideLabels: false,
					labelAlign: 'top',
					layout:'column', // arrange items in columns
					defaults: {      // defaults applied to items
						layout: 'form',
						border: false
					},
					items: [{
						xtype:'fieldset',
						columnWidth: 0.2,
						style: 'padding-right: 4px',
						items :[{
							xtype: 'textfield',
							width: '100%',
							bodyStyle: 'margin-right: 4px',
							name: 'txt-test1',
							disabled: true,
							value: SYSTEM_ID,
							fieldLabel: LBL_SYSTEM_ID_SHORTNAME
						}]
					},{
						xtype:'fieldset',
						columnWidth: 0.4,
						style: 'padding-right: 4px',
						items :[{
							xtype: 'textfield',
							width: '100%',
							bodyStyle: 'margin-right: 4px',
							bodyStyle: 'margin-right: 4px',
							name: 'txt-test2',
							disabled: true,
							value: SYSTEM_NAME,
							fieldLabel: LBL_SYSTEM_ID_LONGNAME
						}]
					}, {
						xtype:'fieldset',
						columnWidth: 0.4,
						items :[{
							xtype: 'textfield',
							width: '100%',
							bodyStyle: 'margin-right: 4px',
							name: 'txt-test3',
							disabled: true,
							value: SYSTEM_ORG,
							fieldLabel: LBL_SYSTEM_ID_ORGANISATION
						}]
					}]
				}]
			}, {
				
				/* System Tabs Panel */
				
				anchor: '100% -95',  // -95 decreases height of inner container to ensure lower scrollbar visibility
				layout: 'fit',
				items: [{
					xtype: 'tabpanel', 
					deferredRender: false,
					enableTabScroll: true,
					activeTab: 0,
					defaults: {autoScroll: true},
					items: [{
						
						/* System Status */
						
						title: LBL_SD_SYSTEM_STATUS_TAB,
						layout: 'border',
						autoScroll: false,
						items: [{
							region: 'north',
							border: false,
							tbar: [{
								text: LBL_SD_SYSTEM_STATUS_BTN_REFRESH,
								tooltip: MSG_SD_SYSTEM_STATUS_BTN_REFRESH_TOOLTIP,
								iconCls:'btnRefresh',
								listeners: {
									'click': function(){
										// Reload content
										//Ext.getCmp('divSystemOverview').html = 'CLEAR';
										Ext.getCmp('divSystemOverview').load({url: SD_GET_DATA_URL, params: 'task=sysstatus', waitMsg:'Loading', nocache: true });
									}
								}
							}]
						}, {
							region: 'center',
							id: 'divSystemOverview',
							deferredRender: false,
							items: pnlSystemOverview,
							autoScroll: true
						}],
						listeners: {
							activate : function(tabpanel) {
								tab = Ext.getCmp('divSystemOverview');
								tab.body.update('');
								tab.load({
									// Note: tab has to be initiated using load or the toolbars are not shown
									url: SD_GET_DATA_URL, 
									params: 'task=sysstatus',
									callback: function(){
										tab.getUpdater().startAutoRefresh( FRAME_RELOAD_INTERVAL, SD_GET_DATA_URL, {task: 'sysstatus'});
									},
									nocache: true,
									waitMsg:'Loading'
								});
							},
							deactivate : function(tabpanel)	{
								Ext.getCmp('divSystemOverview').getUpdater().stopAutoRefresh();
							}						
						}
					}, {
						
						/* System Graphs */
						
						title: LBL_SD_SYSTEM_GRAPHS_TAB,
						layout: 'border',
						autoScroll: false,
						items: [{
							region: 'north',
							border: false,
							tbar: [{
								text: LBL_SD_SYSTEM_GRAPHS_BTN_REFRESH,
								tooltip: MSG_SD_SYSTEM_GRAPHS_BTN_REFRESH_TOOLTIP,
								iconCls:'btnRefresh',
								listeners: {
									'click': function(){
										// Reload content
										var oldts = document.getElementById('timestamp').innerHTML;
										Ext.getCmp('divSystemGraphs').load({url: SD_GET_DATA_URL, params: 'task=sysgraphs&span=' + Ext.getCmp('timespan').value, waitMsg:'Loading', timeout: 120, callback: function(){ if (oldts == document.getElementById('timestamp').innerHTML) { alert ( MSG_SD_SYSTEM_GRAPHS_BTN_REFRESH_FAILED ); } }});
									}
								}
							}, '-', {
								xtype:'combo',
								id: 'timespan',
								typeAhead: true,
								triggerAction: 'all',
								lazyRender: true,
								editable: false,
								width: 130,
								listWidth: 130,
								mode: 'local',
								store: new Ext.data.ArrayStore({
									id: 'day',
									fields: [
										'myId',
										'displayText'
									],
									data: [['day', LBL_SD_SYSTEM_GRAPHS_CBO_INTERVAL_DAY], 
										['week', LBL_SD_SYSTEM_GRAPHS_CBO_INTERVAL_WEEK], 
										['month', LBL_SD_SYSTEM_GRAPHS_CBO_INTERVAL_MONTH], 
										['year', LBL_SD_SYSTEM_GRAPHS_CBO_INTERVAL_YEAR]]
								}),
								valueField: 'myId',
								displayField: 'displayText',
								value: SD_SYSTEM_GRAPHS_CBO_DEFAULT_VALUE,
								listeners: {
									'select': function(){
									// Reload content when span is changed
									Ext.getCmp('divSystemGraphs').load({url: SD_GET_DATA_URL, params: 'task=sysgraphs&span=' + Ext.getCmp('timespan').value, waitMsg:'Loading', timeout: 120 });
									}
								}
							}]
						}, {
							region: 'center',
							id: 'divSystemGraphs',
							deferredRender: false,
							items: pnlSystemGraphs,
							autoScroll: true
						}],
						listeners: {
							activate : function(tabpanel) {
								tab = Ext.getCmp('divSystemGraphs');
								tab.body.update('');
								tab.load({
									// Note: tab has to be initiated using load or the toolbars are not shown
									url: SD_GET_DATA_URL, 
									params: 'task=sysgraphs&span=' + Ext.getCmp('timespan').value,
									callback: function(){
										tab.getUpdater().startAutoRefresh( FRAME_RELOAD_INTERVAL, SD_GET_DATA_URL, {task: 'sysgraphs', span: Ext.getCmp('timespan').value });
									},
									nocache: true,
									waitMsg:'Loading'
								});
							},
							deactivate : function(tabpanel)	{
								Ext.getCmp('divSystemGraphs').getUpdater().stopAutoRefresh();
							}						
						}
					},{
						/* System History Daily */
						
						title: LBL_SD_SYSTEM_HISTORY_DAILY_TAB, 
						layout: 'border',
						autoScroll: false,
						items: [{
							region: 'north',
							border: false,
							tbar: [{
								text: LBL_SD_SYSTEM_STATUS_BTN_REFRESH,
								tooltip: MSG_SD_SYSTEM_STATUS_BTN_REFRESH_TOOLTIP,
								iconCls:'btnRefresh',
								listeners: {
									'click': function(){
										// Reload content
										var fld = Ext.getCmp('detSnortDate');
										var d = new Date.parseDate(fld.value, 'Y-m-d');
										statprep(Ext.getCmp('divSnortReport'), d);
									}
								}
							}, {
								id: 'detSnortDatePrev',
								xtype: 'button',
								text: LBL_SD_SYSTEM_HISTORY_DAILY_BTN_DAY_PREV,
								iconCls:'btnPrev',
								handler: function(){
									var fld = Ext.getCmp('detSnortDate');
									var d = (new Date.parseDate(fld.value,'Y-m-d')).add(Date.DAY, -1);
									fld.setValue(d.format('Y-m-d'));
									statprep(Ext.getCmp('divSnortReport'), d);
								}
							}, {
								xtype: 'panel',
								width: 100,
								autoHeight: true,
								layout: 'fit',
								bodyBorder: false,
								frame: false,
								border: false,
								bodyStyle: 'background-color: transparent; padding-top: 2px;',
								items :[{
									id: 'detSnortDate',
									xtype: 'datefield',
									format: 'Y-m-d',
									minValue: '2009-06-01',
									//minText: 'Date is too old!',
									maxValue: (new Date()).format('Y-m-d'),
									autoWidth: true,
									value: (new Date()).format('Y-m-d'),
									groupRenderer: Ext.util.Format.dateRenderer('M y'),
									editable: false,
									menu: new Ext.menu.DateMenu({
										listeners: {
											select: {
												fn: function (obj) {
													statprep(Ext.getCmp('divSnortReport'), obj.value);
												}
											}
										}
									})
								}]
							}, {
								id: 'detSnortDateNext',
								xtype: 'button',
								text: LBL_SD_SYSTEM_HISTORY_DAILY_BTN_DAY_NEXT,
								frame: true,
								iconAlign: 'right',					
								iconCls:'btnNext',
								handler: function(){
									var fld = Ext.getCmp('detSnortDate');
									var d = (new Date.parseDate(fld.value,'Y-m-d')).add(Date.DAY, 1);
									fld.setValue(d.format('Y-m-d'));
									statprep(Ext.getCmp('divSnortReport'), d);
								}
							}]
						}, {
							region: 'center',
							xtype: 'panel',
							id: 'divSnortReport',
							fitToFrame: true, 
							autoScroll: true 
						}],

						listeners: {
							activate : function(tabpanel) {
								var fld = Ext.getCmp('detSnortDate');
								var d = new Date.parseDate(fld.value, 'Y-m-d');
								statprep(Ext.getCmp('divSnortReport'), d);
							}
						}					
					},{
						/* System logs */
						
						title: LBL_SD_SYSTEM_LOGS_TAB,
						layout: 'border',
						autoScroll: false,
						items: [{
							region: 'north',
							border: false,
							tbar: [{
								text: LBL_SD_SYSTEM_STATUS_BTN_REFRESH,
								tooltip: MSG_SD_SYSTEM_STATUS_BTN_REFRESH_TOOLTIP,
								iconCls:'btnRefresh',
								listeners: {
									'click': function(){
										logprep(Ext.getCmp('log-pane'), historylog);
									}
								}
							}, {
								id: 'btn_log_prev',
								xtype: 'button',
								text: LBL_SD_SYSTEM_LOGS_BTN_PREV,
								tooltip: MSG_SD_SYSTEM_LOGS_BTN_PREV_TOOLTIP,
								handler: function(){
									historylog = historylog + 1;
									btnprep(Ext.getCmp('btn_log_page'), historylog);
									if (historylog >= 0) {
										Ext.getCmp('btn_log_next').enable();
									};
									logprep(Ext.getCmp('log-pane'), historylog);
								},								
								iconCls:'btnPrev'
							}, {
								id: 'btn_log_page',
								xtype: 'button',
								text: '',
								//tooltip: MSG_SD_SYSTEM_LOGS_PAGENR_TOOLTIP,
								disabled: true
							}, {
								id: 'btn_log_next',
								xtype: 'button',
								text: LBL_SD_SYSTEM_LOGS_BTN_NEXT,
								tooltip: MSG_SD_SYSTEM_LOGS_BTN_NEXT_TOOLTIP,
								handler: function(){
									if (historylog >= 0) {
										historylog = historylog - 1;
										btnprep(Ext.getCmp('btn_log_page'), historylog);
										if (historylog < 0) {
											Ext.getCmp('btn_log_next').disable();
										};
										logprep(Ext.getCmp('log-pane'), historylog);
									}
								},
								disabled: true,
								iconAlign: 'right',					
								iconCls:'btnNext'
							}, '-' , {
								xtype: 'tbtext',
								text: LBL_SD_SYSTEM_LOGS_NR_LINES
							}, {
								id: 'nr_log_page',
								xtype: 'numberfield',
								allowBlank: false,
								allowDecimals: false,
								allowNegative: false
							}, {
								xtype:'combo',
								id: 'logfile',
								typeAhead: true,
								triggerAction: 'all',
								lazyRender: true,
								editable: false,
								width: 130,
								listWidth: 130,
								mode: 'local',
								store: new Ext.data.ArrayStore({
									id: 'updater',
									fields: [
										'myId',
										'displayText'
									],
									data: [['updater', LBL_SD_SYSTEM_LOGS_CBO_UPDATER], 
										['alerts', LBL_SD_SYSTEM_LOGS_CBO_ALERTS]]
								}),
								valueField: 'myId',
								displayField: 'displayText',
								value: SD_SYSTEM_LOGS_CBO_DEFAULT_VALUE,
								listeners: {
									'select': function() {
										logprep(Ext.getCmp('log-pane'), historylog);
									}
								}
							}]
						}, {
							region: 'center',
							id: 'log-pane',
							deferredRender: false,
							items: pnlSystemLog,
							autoScroll: true,
							listeners: {
								'render': function(){
										this.on('activate', function(e){
											logprep(Ext.getCmp('log-pane'), historylog);
									}, this, {delegate:'a'});
								}
							}
						}],
						listeners: {
							activate : function(tabpanel) {
									logprep(Ext.getCmp('log-pane'), historylog);
							}
						}					

					},{
						/* System Configuration Overview */
						
						title: LBL_SD_SYSTEM_CONFIGURATION_TAB,
						layout: 'border',
						autoScroll: false,
						items: [{
							region: 'north',
							border: false,
							tbar: [{
								text: LBL_SD_SYSTEM_STATUS_BTN_REFRESH,
								tooltip: MSG_SD_SYSTEM_STATUS_BTN_REFRESH_TOOLTIP,
								iconCls:'btnRefresh',
								listeners: {
									'click': function(){
										// Reload content
										Ext.getCmp('divConfigValues').load({url: SD_GET_DATA_URL, params: 'task=sysconf', waitMsg:'Loading', nocache: true });
									}
								}
							}, {
//								// NOTE: Cert upload is done from command line
								text: LBL_SD_SYSTEM_CONF_BTN_BACKUP,
								tooltip: MSG_SD_SYSTEM_CONF_BTN_BACKUP_TOOLTIP,
								handler: function() {
									window.open(BACKUP_FILE_URL, 'Download');
								},
								iconCls:'btnBackup'
							}]
						}, {
							region: 'center',
							id: 'divConfigValues',
							autoScroll: true,
							autoLoad: { url: SD_GET_DATA_URL, params: 'task=sysconf' }
						}],
						listeners: {
							activate : function(tabpanel)	{
								Ext.getCmp('divConfigValues').body.update('');
								Ext.getCmp('divConfigValues').load({url: SD_GET_DATA_URL, params: 'task=sysconf', waitMsg:'Loading', nocache: true });
							}
						}
					}]
				}]
			}]
		}]
	});
	
}); //end onReady

function statprep(obj, date){
	var urlpath = SYSTEM_HISTORY_DAILY_URL_PATH + '?yy=' + date.format('Y') + '&md=' + date.format('m') + date.format('d');
	var iframeparams = '"frameborder="0" scrolling="auto" style="border:0px none;" width="100%" height="100%"';
	obj.body.update('<iframe id="center-iframe" src="' + urlpath + ' ' + iframeparams + '></iframe>');
}

function logprep(obj, nmb){
	var lines = Ext.getCmp('nr_log_page').getValue();
	var file = Ext.getCmp('logfile').value;
	var urlpath = SYSTEM_LOGVIEW_URL_PATH + '?log=' + nmb + '&lines=' + lines + '&file=' + file;
	var iframeparams = '"frameborder="0" scrolling="auto" style="border:0px none;" width="100%" height="100%"';
	obj.body.update('<iframe id="center-iframe" src="' + urlpath + ' ' + iframeparams + '></iframe>');
}

function btnprep(obj, nmb){

	if (nmb < 0) {
		obj.setText('');
	}
	else if (nmb == 0) {
		obj.setText('0');
	}
	else {
		obj.setText(nmb);
	}
}
