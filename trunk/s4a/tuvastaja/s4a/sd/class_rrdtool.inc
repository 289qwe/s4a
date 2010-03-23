<?php

/*
 * Copyright (c) 2003 Willem Dijkstra
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 *    - Redistributions of source code must retain the above copyright
 *      notice, this list of conditions and the following disclaimer.
 *    - Redistributions in binary form must reproduce the above
 *      copyright notice, this list of conditions and the following
 *      disclaimer in the documentation and/or other materials provided
 *      with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 * COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
 * ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 *
 */

/*
 * This class provides a convenient interface to rrdtool.
 */

function hash2cmdline(&$args) {
    reset($args);
    $cmdline = '';

    foreach($args as $key => $value) {
        $cmdline .= " ".escapeshellarg($value);
    }

    return $cmdline;
}

function config_error($item, $problem) {
    print("\xa\xa".'check '.$item.": ".$problem);
    exit(1);
}



class RRDTool {
    var $cmdline;
    var $error;
    var $output;

    function RRDTool() {
	global $CONFIG; 
	$CONFIG['grapher_rrdtool_path'] = '/bin/rrdtool';
	$this->method = '';

	if (isset($CONFIG['grapher_rrdtool_path'])) {
	    if (!is_executable($CONFIG['grapher_rrdtool_path'])) {
		config_error('grapher_rrdtool_path', 'is not an executable');
		return 0;
	    }
	} else {
	    config_error('grapher_rrdtool_path', 'is not set');
	    return 0;
	}

	return 1;
    }

    function graph($filename, $common, $range, $type, $rrdname) {
	global $CONFIG;
	$CONFIG['grapher_rrdtool_path'] = '/bin/rrdtool';

	$args = array();
	
	for ($i = 0; $i < count($common); $i++) {
		array_push($args, $common[$i]);
	}

	for ($i = 0; $i < count($range); $i++) {
		array_push($args, $range[$i]);
	}

	for ($i = 0; $i < count($type); $i++) {
		if (preg_match("/DEF:\S+=.*(XrrdnameX)\.\S+\.rrd:ds\d:AVERAGE/",
				$type[$i], $match)) {
			array_push($args,
				str_replace('XrrdnameX', $rrdname, $type[$i]));
		} else {
			array_push($args, $type[$i]);
		}
	}

	$cmdline = $CONFIG['grapher_rrdtool_path'] . ' graph '. $filename .
	    hash2cmdline($args) . ' 2>&1';


	$result = $this->exec($cmdline);


	if ($result == 0) {
	    $output = "<HR>\xa Error from rrd: ".$this->get_error();
	    $output = $output."<p>\xa RRD output:".$this->get_output();
	    $output = $output."<p>\xa rrdtool \xa cmdline: '$cmdline'";
	    printf("%s", $output);
	}

	return $result;
    }

    function get_error() {
	return $this->error;
    }

    function get_output() {
	return $this->output;
    }

    function _test() {
	global $CONFIG;
	$CONFIG['grapher_rrdtool_path'] = '/bin/rrdtool';

	$cmdline = $CONFIG['grapher_rrdtool_path'] . ' -v';
	if ($this->exec($cmdline) == 0) {
	    runtime_error('apache or php setup faulty: cannot execute '.$CONFIG['grapher_rrdtool_path']);
	    return 0;
	} else {
	    $version_info = $this->get_output();
	    if (strlen($version_info) == 0) {
		runtime_error('apache or php setup faulty: can execute '.$CONFIG['grapher_grapher_rrdtool_path']. ', but no results are returned');
		return 0;
	    } else {
		print "\xa rrdtool version: ";
		if (preg_match("/rrdtool\s+(\S+)/i", $version_info, $match)) {
		    print $match[1];
		} else {
		    print "unknown";
		}
		return 1;
	    }
	}
    }

    function exec($cmdline) {
	global $runtime;

	$this->error = '';
	$this->output = '';
	$this->cmdline = $cmdline;

	unset($reta);
	exec($cmdline, $reta, $ret);

	if ($ret != 0) {
	    foreach($reta as $key => $value) {
		$this->error .= '<pre>'.$value.'</pre><br>';
	    }
	    return 0;
	} else {
	    foreach($reta as $value) {
		if ($value != "") {
		    $this->output .= '<p>'.$value.'</p>';
		}
	    }
	    if (strstr($this->output, '<p>ERROR:')) {
		return 0;
	    }
	    return 1;
	}
	return 1;
    }
}
?>
