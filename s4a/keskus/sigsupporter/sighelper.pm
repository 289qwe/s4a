#!/usr/bin/perl

# /* Copyright (C) 2010, Cybernetica AS, http://www.cybernetica.eu/ */


use strict;
use warnings;

# Regexp to match the start of a multi-line rule.
# %ACTIONS% will be replaced with content of $config{actions} later.
my $MULTILINE_RULE_REGEXP  = '^(?:%ACTIONS%)\s.*\\\\\s*\n$'; # ';
#my $MULTILINE_RULE_REGEXP  = '^\s*#*\s*(?:%ACTIONS%)\s.*\\\\\s*\n$'; # ';

# Regexp to match a single-line rule.
my $SINGLELINE_RULE_REGEXP = '^(?:%ACTIONS%)\s.+;\s*\)\s*$'; # ';
#my $SINGLELINE_RULE_REGEXP = '^\s*#*\s*(?:%ACTIONS%)\s.+;\s*\)\s*$'; # ';

my %config;

$config{rule_actions} = "alert|drop|log|pass|reject|sdrop|activate|dynamic";

$SINGLELINE_RULE_REGEXP =~ s/%ACTIONS%/$config{rule_actions}/;
$MULTILINE_RULE_REGEXP  =~ s/%ACTIONS%/$config{rule_actions}/;

# Same as in oinkmaster.pl.
sub get_next_entry($ $ $ $ $ $)
{
	my $arr_ref = shift;
	my $single_ref = shift;
	my $multi_ref = shift;
	my $nonrule_ref = shift;
	my $msg_ref = shift;
	my $sid_ref = shift;

	undef($$single_ref);
	undef($$multi_ref);
	undef($$nonrule_ref);
	undef($$msg_ref);
	undef($$sid_ref);

	my $line = shift(@$arr_ref) || return(0);
	my $disabled = 0;
	my $broken = 0;

	# Possible beginning of multi-line rule?
	if ($line =~ /$MULTILINE_RULE_REGEXP/oi) {
		$$single_ref = $line;
		$$multi_ref = $line;
		$disabled = 1 if ($line =~ /^\s*#/);

		# Keep on reading as long as line ends with "\".
		while (!$broken && $line =~ /\\\s*\n$/) {

			# Remove trailing "\" and newline for single-line version.
			$$single_ref =~ s/\\\s*\n//;

			# If there are no more lines, this can not be a valid multi-line rule.
			if (!($line = shift(@$arr_ref))) {
				warn("\nWARNING: got EOF while parsing multi-line rule: $$multi_ref\n") 
					if ($config{verbose});
				@_ = split(/\n/, $$multi_ref);
				undef($$multi_ref);
				undef($$single_ref);

				# First line of broken multi-line rule will be returned as a non-rule line.
				$$nonrule_ref = shift(@_) . "\n";
				$$nonrule_ref =~ s/\s*\n$/\n/; # remove trailing whitespaces

				# The rest is put back to the array again.
				foreach $_ (reverse((@_))) {
					unshift(@$arr_ref, "$_\n");
				}

				return (1); # return non-rule
			}

			# Multi-line continuation.
			$$multi_ref .= $line;

			# If there are non-comment lines in the middle of a disabled rule,
			# mark the rule as broken to return as non-rule lines.
			if ($line !~ /^\s*#/ && $disabled) {
				$broken = 1;
			} 
			elsif ($line =~ /^\s*#/ && !$disabled) {
				# comment line (with trailing slash) in the middle of an active rule - ignore it
			} 
			else {
				$line =~ s/^\s*#*\s*//; # remove leading # in single-line version
				$$single_ref .= $line;
			}

		} # while line ends with "\"

		# Single-line version should now be a valid rule.
		# If not, it wasn't a valid multi-line rule after all.
		if (!$broken && parse_singleline_rule($$single_ref, $msg_ref, $sid_ref)) {
			$$single_ref =~ s/^\s*//; # remove leading whitespaces
			$$single_ref =~ s/^#+\s*/#/; # remove whitespaces next to leading #
			$$single_ref =~ s/\s*\n$/\n/; # remove trailing whitespaces
			$$multi_ref =~ s/^\s*//;
			$$multi_ref =~ s/\s*\n$/\n/;
			$$multi_ref =~ s/^#+\s*/#/;
			return (1); # return multi
		} 
		else {
			warn("\nWARNING: invalid multi-line rule: $$single_ref\n") 
				if ($config{verbose} && $$multi_ref !~ /^\s*#/);
			@_ = split(/\n/, $$multi_ref);
			undef($$multi_ref);
			undef($$single_ref);

			# First line of broken multi-line rule will be returned as a non-rule line.
			$$nonrule_ref = shift(@_) . "\n";
			$$nonrule_ref =~ s/\s*\n$/\n/; # remove trailing whitespaces

			# The rest is put back to the array again.
			foreach $_ (reverse((@_))) {
				unshift(@$arr_ref, "$_\n");
			}

			return (1); # return non-rule
		}

	} 
	elsif (parse_singleline_rule($line, $msg_ref, $sid_ref)) {
		$$single_ref = $line;
		$$single_ref =~ s/^\s*//;
		$$single_ref =~ s/^#+\s*/#/;
		$$single_ref =~ s/\s*\n$/\n/;

		return (1); # return single
	} 
	else { # non-rule line
		# Do extra check and warn if it *might* be a rule anyway,
		# but that we just couldn't parse for some reason.
		warn("\nWARNING: line may be a rule but it could not be parsed (missing sid or msg?): $line\n") 
			if ($config{verbose} && $line =~ /^\s*alert .+msg\s*:\s*".+"\s*;/);

		$$nonrule_ref = $line;
		$$nonrule_ref =~ s/\s*\n$/\n/;

		return (1); # return non-rule
	}
}

# Same as in oinkmaster.pl.
sub parse_singleline_rule($ $ $)
{
	my $line = shift;
	my $msg_ref = shift;
	my $sid_ref = shift;

	if ($line =~ /$SINGLELINE_RULE_REGEXP/oi) {
		if ($line =~ /\bmsg\s*:\s*"(.+?)"\s*;/i) {
			$$msg_ref = $1;
		} 
		else {
			return (0);
		}

		if ($line =~ /\bsid\s*:\s*(\d+)\s*;/i) {
			$$sid_ref = $1;
		} 
		else {
			return (0);
		}

		return (1);
	}

	return (0);
}


sub get_sidmap($ $)
{
	my $tarfile = shift;
	my $map_ref = shift;

	my $workdir = "/tmp/" . time();

	if (-d $workdir) {
		warn("Directory $workdir already exists");
		return 0;
	}

	mkdir($workdir);

	if (! -d $workdir) {
		warn("Couldn't create $workdir");
		return 0;
	}

	my $tarcmd = "/bin/tar -x -z -f $tarfile -C $workdir > /dev/null";
	if (system("$tarcmd") != 0) {
		warn("Error executing tar");
		return 0;
	}

	# Files to ignore.
	my %skipfiles = (
		'deleted.rules' => 1,
	);

	my $rulesdir = "$workdir/sid";

	# Read in all rules from each rules file (*.rules) in each rules dir.
	# into $map_ref.
	opendir(RULESDIR, "$rulesdir") or die("could not open \"$rulesdir\": $!\n");

	while (my $file = readdir(RULESDIR)) {
		next unless ($file =~ /\.rules$/);
		next if ($skipfiles{$file});

		open(FILE, "$rulesdir/$file") or die("could not open \"$rulesdir/$file\": $!\n");
		my @file = <FILE>;
		close(FILE);

		my ($single, $multi, $nonrule, $msg, $sid);

		while (get_next_entry(\@file, \$single, \$multi, \$nonrule, \$msg, \$sid)) {

			if (defined($single)) {
				warn("WARNING: duplicate SID: $sid (discarding old)\n") if (exists(${$map_ref}{$sid}));
				${$map_ref}{$sid} = {'MSG' => "$msg", 'LINE' => "$single"};
			}
		}
	}

	my $rmcmd = "/bin/rm -rf $workdir";
	if (system("$rmcmd") != 0) {
		warn("Error executing rm");
		return 0;
	}
	return 1;
}

sub check_rrd_allocation($ $)
{
	my $alloc_ref = shift;
	my $cur_ref = shift;

	foreach my $sid (keys %{$cur_ref}) {
		if (!defined(${$alloc_ref}{$sid})) {
			warn("No allocation for sid $sid");
			return 0;
		}
	}

	my %rrds = ();
	foreach my $sid (keys %{$alloc_ref}) {
		if (!defined(${$cur_ref}{$sid})) {
			warn("Allocated sid $sid not in ruleset");
			return 0;
		}

		my $rrd = ${$alloc_ref}{$sid}{'RRD'};
		my $ds = ${$alloc_ref}{$sid}{'DS'}; 

		if (defined($rrds{$rrd}{$ds})) {
			warn("DS $ds allocated twice in RRD $rrd");
			return 0;
		}

		$rrds{$rrd}{$ds} = 1;
	}

	return 1;
}

sub get_rrd_allocation($)
{
	my $alloc_ref = shift;

	my $alloc_file = "/var/www/etc/s4a-map";

	if (! -e $alloc_file) {
		warn("File doesn't exist: $alloc_file");
		return 0;
	}	

	if(!open(DATA, "<$alloc_file") ) {
		warn("Couldn't open $alloc_file");
		return 0;
	}

	while (<DATA>) {
		chomp;
		my @row = split(/\t/, $_, 4);
		if (!(@row and defined($row[0]) and defined($row[1]) and defined($row[2]) and defined($row[3]))) {
			close(DATA);
			return 0;
		}

		${$alloc_ref}{$row[0]} = { 'RRD' => $row[1], 'DS' => $row[2], 'MSG' => $row[3] };
	}

	close(DATA);
	
	return 1;

}

sub get_current($)
{
	my $cur_ref = shift;
	undef($$cur_ref);

	my $ret = 0;

	my $sigdir = "/var/www/confserv/signatures";
	my $sigverfile = "current-";
	my $sigfile = "signatures-";
	my $verinfo = "4.6";

	if( -d "$sigdir" ) {
		my $curverfile = "$sigdir/$sigverfile$verinfo";
		my $curver = readCursigdate($curverfile);
		if ($curver == 0) {
			# normal situation - no current
			$ret = 1;
		}
		else {
			my $cursigfile = "$sigdir/$sigfile$curver.tgz";
			if ( -e $cursigfile) {
				$ret = 1;
				$$cur_ref = $cursigfile;
			}
			else {
				warn("$cursigfile is missing!\n");
			}
		}
	}
	else {
		warn("$sigdir is missing!\n");
	}

	return $ret;
}


sub check_sidfile($)
{
	my ($filee) = @_;
	my $tarcmd = "/bin/tar tzf $filee > /dev/null";

	if (system("$tarcmd") != 0) {
		warn("Error executing tar");
		return 0;
	}

	if ( !open(DATA, "/bin/tar tzf $filee |") ) {
		warn("Can't execute tar!: $!");
		return 0;
	}

	while (defined(my $line = <DATA>)) { 
		chomp($line); 
		if ($line =~ /^sid\/|^sid$|^conf\/|^conf$/) {
			next;
		}
		warn("Illegal file in archive: $line");
		close DATA;
		return 0;
	}
	close DATA; 
	return 1;
}

sub writeCursigdate($$)
{
	my ($filee, $date) = @_;

	if (!open(DATA, ">$filee.$$")) {
		warn("Open($filee.$$) error: $!"); 
		return 0;
	}

	printf(DATA "$date\n");

	if (!close(DATA)) {
		warn("Close($filee.$$) error: $!"); 
		return 0;
	}

	if (!rename("$filee.$$", "$filee")) {
		warn("Rename($filee.$$,$filee) error: $!"); 
		return 0;
	}
	return 1;
}

sub readCursigdate($)
{
	my ($filee) = @_;
	if( !open(DATA, "<$filee") ) {
		return(0);
	}

	my $ret = <DATA>;
	if ($ret =~ /\n$/) {
		chop($ret);
	}
	close(DATA);
	return($ret);
}


1;

