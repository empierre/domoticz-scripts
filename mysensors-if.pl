#!/usr/bin/perl -w
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# version 2 as published by the Free Software Foundation.
# Author: epierre
use warnings;
use strict;
use POSIX qw(strftime);
use Device::SerialPort;
use IO::Handle;
use DateTime;
use Scalar::Util qw(looks_like_number);
use DBI;
use Config::Simple;

# Initialization strings
my $conf = ".conf-mysensors";
my $ccnt;
my $cfg;
my ($count, $string, $radioId, $value);
my $Config=&read_conf($conf);
my $port = $Config->{"Internal.usb_port"};
my $gw_ip = $Config->{"Internal.gw_ip"};
my $gw_port = $Config->{"Internal.gw_port"};
my $dbh;
my %sensor_tab;


# USB port opening
my $ob = &connect_usb($port);
$ob->close || warn "close failed";;
$ob = &connect_usb($port);
my $sleep = 5;
print "Sleeping $sleep second to let arduino get ready...\n";
sleep $sleep;

# Now parse output
my @vals;
open(FIC,">>log-gw.txt")||die $!;
print FIC "Starting\n";
FIC->autoflush(1);
while(1) {
       $ccnt++;
       $ob->lastline("\n");

       ($count, $string) = $ob->read(255);

       #print "$ccnt $string\n\n";
       @vals  = split("\n", $string);
       foreach (@vals) {
               $_=~ s/\t/\=/;
               $_=~ s/\r//;
               $_=~ s/\n//;
                my ($radioId, $childId,$messageType,$subType,$payload) = split(";", $_);
                if (! $childId) {$childId="0";}
                if (! $messageType) {$messageType="0";}
                if (! $subType) {$subType="0";}
                if (! $payload) {$payload="0";}
                next unless ($radioId);
                next if (! looks_like_number $radioId);
                #$value = 0 unless ($value);
                #$value = $value/1000 if $radioId =~ /I/g;
                my $dt = DateTime->now;
                my $date=join ' ', $dt->ymd, $dt->hms;
                print "$date $radioId $childId $messageType $subType $payload\n";
                if ($radioId==1) {
                        print FIC "$date $radioId $childId $messageType $subType $payload\n";
                }

				`curl -s "http://$gw_ip:$gw_port/message/$radioId/$childId/$messageType/$subType/$payload" &`;
		}
        sleep(1);


}
close(FIC);
$ob->write_drain;
$ob->close;
undef $ob;

sub connect_usb {
	my $port=$_[0];
	Device::SerialPort->new($port, 1) || die "Can't open $port: $ +!"; 
	$ob = Device::SerialPort->new($port, 1) || die "Can't open $port: $ +!";
	$ob->databits(8);
	$ob->baudrate(115200);
	$ob->parity("none");
	$ob->stopbits(1);
	$ob->buffers( 4096, 4096 );
	$ob->write_settings();
	return $ob;
}

sub read_conf {
	my $conf=$_[0];
	$cfg = new Config::Simple($conf) or die Config::Simple->error();;
	$cfg->autosave(1);
	# getting the values as a hash:
	my %Config = $cfg->vars();
	return \%Config;
	#$user = $cfg->param("mysql.user")
	#$cfg->param("User", "tom");
	#$cfg->delete('mysql.user'); 
}
sub save_conf {
	$cfg=$_[0];
	$cfg->save();
}
