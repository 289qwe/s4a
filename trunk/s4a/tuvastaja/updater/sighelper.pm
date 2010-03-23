#!/usr/bin/perl

# /* Copyright (C) 2010, Cybernetica AS, http://www.cybernetica.eu/ */


use strict;
use warnings;




sub my_mac()
{
	my $interf=readvar("IFACE.var");
	my $mac = '';

	if( !open(DATA, "/sbin/ifconfig $interf |") ) {
		syslog(LOG_WARNING, "Cant execute ifconfig!: $!");
		return;
	}
	
	while (defined(my $line = <DATA>)) { 
		if ($line =~ /\n$/) {
			chomp($line); 
		}
		if ($line =~ /^\s+lladdr (.*)$/) {
			$mac=$1;
			last;
		}
	}
	close DATA; 
	return($mac);
}
	

sub check_sidfile($)
{
	my($filee) = @_;
	my $tarcmd="/bin/tar tzf $filee > /dev/null";
	my $okfile=1;

	if(system("$tarcmd") == 0) {
		# korralik TAR vaatame sisse
		if( !open(DATA, "/bin/tar tzf $filee |") ) {
			syslog(LOG_WARNING, "Cant execute tar!: $!");
			$okfile=0;
			next;
		}
		
		while (defined(my $line = <DATA>)) { 
			chomp($line); 
			if ($line =~ /^sid\/|^sid$|^conf\/|^conf$/) {
				next;
			}
			printf("Illegal file in archive: $line\n");
			$okfile=0;
		}
		close DATA; 
	} else {
		$okfile=0;
	}
	return($okfile);
}

sub writeCursigdate($$)
{
	my ($filee, $date) = @_;
	my $ret = 0;

	if( !open(DATA, ">$filee.$$") ) {
		syslog(LOG_WARNING, "Open($filee.$$) error: $!"); 
		return($ret);
	}

	printf(DATA "$date\n");

	if(!close(DATA)) {
		syslog(LOG_WARNING, "Close($filee.$$) error: $!"); 
		return($ret);
	}
	if(!rename("$filee.$$", "$filee")) {
		syslog(LOG_WARNING, "Rename($filee.$$,$filee) error: $!"); 
		return($ret);
	}
	$ret = 1;
	return($ret);
}

sub readCursigdate($)
{
	my ($filee) = @_;
	my $ret=readlinefromx("<$filee");
	if($ret eq '') {
		$ret = 0;
	}
	return($ret);
}
sub read1frompipe($)
{
	my ($filee) = @_;
	return(readlinefromx("$filee |"));
}

sub readvar($)
{
	my ($filee) = @_;
	my $vardir="/var/www/tuvastaja/data/conf/";
	return(readlinefromx("<$vardir$filee"));
}

sub varexists($)
{
	my ($filee) = @_;
	my $vardir="/var/www/tuvastaja/data/conf/";
	if( !open(DATA, "<$vardir$filee") ) {
		return(0);
	}
	close(DATA);
	return(1);
	
}

sub readlinefromx($)
{
	my ($filee) = @_;

	if( !open(DATA, "$filee") ) {
		# printf("Debug: $filee: %s\n", $!);
		return('');
	}

	# huvitab 1 rida
	my $ret = <DATA>;
	if ($ret =~ /\n$/) {
		chop($ret);
	}
	close(DATA);
	return($ret);
}




1;

