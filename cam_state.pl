#!/usr/bin/perl
#Get the recording status capabilities of the camera

$a= `/usr/bin/curl -s 'http://192.168.0.25:88/cgi-bin/CGIProxy.fcgi?cmd=getMotionDetectConfig&usr=admin1&pwd=eadqcw21' ` ;

($status_lnk)=($a=~/linkage>(\d)<\//);

print "test: $cam $status_lnk\n";

if (($status_lnk==0)&&(-e "/var/tmp/enr_on.$cam")) {
        print "enr off";
        unlink "/var/tmp/enr_on.$cam";
        `/usr/bin/curl -s "http://192.168.0.24:8080/json.htm?type=command&param=switchlight&idx=12&switchcmd=Off"`;
};

if (($status_lnk>0)&&(! -e "/var/tmp/enr_on.$cam")) {
        print "enr on";
        system("touch /var/tmp/enr_on.$cam");
        `/usr/bin/curl -s "http://192.168.0.24:8080/json.htm?type=command&param=switchlight&idx=12&switchcmd=On"`;
}

