/* Copyright (C) 2010, Cybernetica AS, http://www.cybernetica.eu/ */

Ext.BLANK_IMAGE_URL = '../ext3/resources/images/default/s.gif';

Ext.onReady(function(){

	var button = Ext.get('show-btn');
	var graph_left = 51;
	var graph_top = 22;
	var graph_width = 600;
	var graph_height = 300;
	var image_width = 681;
	var image_height = 368;
	var old_values = [];

	var img_url = 'rrdgraph.php';
	var allowed_left = graph_left + 1;
	button.on('click', function() {

		var my_shade = new Ext.BoxComponent({
			style: {
				'background': 'red',
				'opacity': .5
			}
		});


		var slider_up = new Ext.Slider({
			width: image_width,
			value: graph_width + graph_left,
			increment: 1,
			minValue: 0,
			maxValue: image_width,
			listeners: {
				'change': function(slid, newval) {
					if (newval < allowed_left) {
						slid.setValue(allowed_left, false);
						return;
					}
					if (newval > graph_left + graph_width) {
						slid.setValue(graph_left + graph_width, false);
						return;
					}
					if (newval > slider_down.getValue()) {
						slid.setValue(slider_down.getValue(), false);
						return;
					}
					obj = my_shade.getBox(true);
					obj.x = newval;
					my_shade.setWidth(slider_down.getValue() - slider_up.getValue());
					my_shade.setPosition(obj.x, obj.y);
				}
			}
		});

		var slider_down = new Ext.Slider({
			width: image_width,
			value: graph_width + graph_left,
			increment: 1,
			minValue: 0,
			maxValue: image_width,
			listeners: {
				'change': function(slid, newval) {
					if (newval < allowed_left) {
						slid.setValue(allowed_left, false);
						return;
					}
					if (newval > graph_left + graph_width) {
						slid.setValue(graph_left + graph_width, false);
						return;
					}
					if (newval < slider_up.getValue()) {
						slid.setValue(slider_up.getValue(), false);
						return;
					}
					obj = my_shade.getBox();
					obj.width = slider_down.getValue() - slider_up.getValue();
					my_shade.updateBox(obj);
				}
			}
		});

		var my_image = new Ext.BoxComponent({
			width: image_width,
			height: image_height,
			autoEl: {
				tag: 'img',
				src: img_url + '?start_time=' + old_start_time + '&end_time=' + old_end_time + '&sig_id=' + sig_id
			}
		});

		var my_setbtn = new Ext.Button({
			text: 'Rakenda',
			listeners: {
				'click': function() {

					realzoom.remove(0);
					var old1 = old_start_time;
					var old2 = old_end_time;					

					var x1 = slider_up.getValue() - graph_left;
					var x2 = slider_down.getValue() - graph_left;

					var nstart_time = Math.round(old1 + (((old2 - old1) / graph_width) * x1));
					var nend_time = Math.round(old1 + (((old2 - old1) / graph_width) * x2));

					var inimg_url = img_url + '?start_time=' + nstart_time + '&end_time=' + nend_time + '&sig_id=' + sig_id;

					var new_image = new Ext.BoxComponent({
						width: image_width,
						height: image_height,
						autoEl: {
							tag: 'img',
							src: inimg_url
						}
					});
					g_image_b = true;

					old_values.push({olds : old_start_time, olde : old_end_time});
					my_backbtn.enable();

					old_start_time = nstart_time;
					old_end_time = nend_time;
					
					slider_up.setValue(graph_width + graph_left);
					slider_down.setValue(graph_width + graph_left);

					my_shade.setSize(0, graph_height);
					my_shade.setPosition(graph_width + graph_left, graph_top);

					realzoom.insert(0, new_image);
					realzoom.doLayout();
				}
			}
		});


		var my_backbtn = new Ext.Button({
			text: 'Tagasi',
			disabled: true,
			listeners: {
				'click': function() {
					realzoom.remove(0);

					obj = old_values.pop();
					old_start_time = obj.olds;
					old_end_time = obj.olde;					
					
					if (old_values.length == 0) {
						my_backbtn.disable();
					}

					var inimg_url = img_url + '?start_time=' + old_start_time + '&end_time=' + old_end_time + '&sig_id=' + sig_id;
					var new_image = new Ext.BoxComponent({
						width: image_width,
						height: image_height,
						autoEl: {
							tag: 'img',
							src: inimg_url
						}
					});
					
					slider_up.setValue(graph_width + graph_left);
					slider_down.setValue(graph_width + graph_left);

					my_shade.setSize(0, graph_height);
					my_shade.setPosition(graph_width + graph_left, graph_top);

					realzoom.insert(0, new_image);
					realzoom.doLayout();
				}
			}
		});

		var my_resetbtn = new Ext.Button({
			text: 'Alusta algusest',
			listeners: {
				'click': function() {
					realzoom.remove(0);

					old_values = null;
					old_values = [];
					
					var dd = new Date();
					old_end_time = Math.round((dd.getTime() / 1000));
					old_start_time = old_end_time - 172800;
					my_backbtn.disable();

					var inimg_url = img_url + '?start_time=' + old_start_time + '&end_time=' + old_end_time + '&sig_id=' + sig_id;
					var new_image = new Ext.BoxComponent({
						width: image_width,
						height: image_height,
						autoEl: {
							tag: 'img',
							src: inimg_url
						}
					});
					
					slider_up.setValue(graph_width + graph_left);
					slider_down.setValue(graph_width + graph_left);

					my_shade.setSize(0, graph_height);
					my_shade.setPosition(graph_width + graph_left, graph_top);

					realzoom.insert(0, new_image);
					realzoom.doLayout();
				}
			}
		});


		var realzoom = new Ext.Container({
			width: image_width,
			height: image_height,
			layout: 'absolute',
			items: [
				my_image,
				my_shade
			]
		});

		var buttonbox = new Ext.Container({
			layout: 'hbox',
			items: [
				my_setbtn,
				my_backbtn,
				my_resetbtn
			]
		});

		var zoombox = new Ext.Container({
			width: image_width,
			items: [
				slider_up,
				realzoom,
				slider_down,
				buttonbox
			]
		});

		var nav = new Ext.Panel({
			title: signature,
			region: 'center',
			split: true,
			width: image_width,
			collapsible: false,
			padding: 10,
			items: zoombox
		});

		var win = new Ext.Window({
			title: 'RRD zoomer',
			closable:true,
			width:image_width + 50,
			height:550,
			plain:true,
			layout: 'border',
			items: nav
		});

		my_shade.setSize(0, graph_height);
		my_shade.setPosition(graph_width + graph_left, graph_top);
		win.show(this);

	});

});

