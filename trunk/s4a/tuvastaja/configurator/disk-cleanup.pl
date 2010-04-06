#!/usr/bin/perl -w

# /* Copyright (C) 2010, Cybernetica AS, http://www.cybernetica.eu/ */


use Filesys::Df;

$max_percent = 80;

sub disk_used {
	my $fs = shift @_;
	my $diskdata = df($fs);
	return $diskdata->{per};
}

# what mountpoint to df
# what patterns to select oldest files from for removing,
# what percentage of disk usage is allowed as maximum
sub clean_partition {
	my $mountpoint = shift;
	my $dirs = shift;
	my $max_usage = shift;

	my $oldest = time();
	foreach $file (`find $dirs -type f 2>/dev/null`) { # ignore errors from missing files
		chomp $file;
		my $mtime = (stat $file)[9];
		$oldest = $mtime if $mtime < $oldest;
	}

	my $i = int((time() - $oldest) / 86400);
	while ($i > 1 && disk_used($mountpoint) > $max_usage) {
		#print "Cleanig $i days old files\n";
		system("find $dirs -mtime +$i -type f -exec rm {} \\;");
		sleep 60; # let df catch up
		$i--;
	}
}

clean_partition("/var/www/tuvastaja/data", "/var/www/tuvastaja/data/snort-logs /var/www/tuvastaja/data/snort-reports /var/www/tuvastaja/data/updater-logs/*.*", $max_percent);
clean_partition("/", "/var/log/*.[0-9]* /var/www/logs/*.[0-9]*", $max_percent);
