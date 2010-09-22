<?php

/*
 * Copyright (C) 2010, Cybernetica AS, http://www.cybernetica.eu/
 * */

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
?>
