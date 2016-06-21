#!/usr/bin/perl -w
use File::stat;
use POSIX ();
use Time::localtime;


my $fh='/home/pi/log-gw.txt';
if (-e $fh) {
	my $epoch_timestamp = stat($fh)->mtime;
	my $timestamp = localtime($^T);

	my $res_timestamp = $^T-$epoch_timestamp;
	if ($res_timestamp >= 10*60) {
		print "old $res_timestamp $^T";
		open(FIC,'/tmp/mgw.pid')||warn $!;
		my $pid=<FIC>;
		close(FIC);
		my $cnt = kill 'HUP', $pid;
		system("nohup /home/pi/mysensors-gw1.4.pl &")
	} 
}
