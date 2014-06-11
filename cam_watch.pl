#!/usr/bin/perl

use Fcntl qw(LOCK_EX LOCK_NB);
use File::NFSLock;

# Try to get an exclusive lock on myself.
my $lock = File::NFSLock->new($0, LOCK_EX|LOCK_NB);
die "$0 is already running!\n" unless $lock;

while (1) {
$a= `/usr/bin/curl -s 'http://192.168.0.25:88/cgi-bin/CGIProxy.fcgi?cmd=getDevState&usr=epierre&pwd=tititoto' ` ;

($status)=($a=~/motionDetectAlarm>(\d)<\//);
($status_rec)=($a=~/record>(\d)<\//);
($cam)=($a=~/http%3A%2F%2F(.+)\.myfoscam/);

#print "test: $cam $status\n";
if (($status==1)&&(-e "/var/tmp/alarm_on.$cam")) {
	#motion sensor
        print "alarm off";
        unlink "/var/tmp/alarm_on.$cam";
        `/usr/bin/curl -s "http://192.168.0.24:8080/json.htm?type=command&param=switchlight&idx=8&switchcmd=Off"`;
};

if (($status==2)&&(! -e "/var/tmp/alarm_on.$cam")) {
	#motion sensor
        print "alarm on";
        system("touch /var/tmp/alarm_on.$cam");
        `/usr/bin/curl -s "http://192.168.0.24:8080/json.htm?type=command&param=switchlight&idx=8&switchcmd=On"`;
}

if (($status_rec==0)&&(-e "/var/tmp/rec_on.$cam")) {
	#PIR1_Rec
        print "rec off";
        unlink "/var/tmp/rec_on.$cam";
        `/usr/bin/curl -s "http://192.168.0.24:8080/json.htm?type=command&param=switchlight&idx=11&switchcmd=Off"`;
};

if (($status_rec>0)&&(! -e "/var/tmp/rec_on.$cam")) {
	#PIR1_Rec
        print "rec on";
        system("touch /var/tmp/rec_on.$cam");
        `/usr/bin/curl -s "http://192.168.0.24:8080/json.htm?type=command&param=switchlight&idx=11&switchcmd=On"`;
}

	sleep(10);
}
