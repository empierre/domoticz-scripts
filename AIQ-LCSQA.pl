#!/usr/bin/perl
use v5.14;
use LWP::Simple;                # From CPAN
use XML::Simple;                # From CPAN
use strict;                     # Good practice
use warnings;                   # Good practice
use utf8;    
use POSIX;
use feature     qw< unicode_strings >;
#Support: domoticz@e-nef.com ou forum Domoticz

#Pour ajouter les librairies nécessaires:
#sudo apt-get install libjson-perl libdatetime-perl libwww-perl libxml-simple-perl

#A adapter à votre configuration:
my $domo_ip="192.168.0.28";
my $domo_port="8080";
my $agglomeration="PARIS";
my $dz_ind=211; #ID d'un device virtuel de type CO2 pour tous les suivants
my $dz_o3=220;
my $dz_no2=221;
my $dz_so2=222;
my $dz_pm10=219;

#Ne pas toucher en dessous
my $trendsurl = " http://www.lcsqa.org/surveillance/indices/prevus/jour/xml/";

my $json = get( $trendsurl );
die "Could not get $trendsurl!" unless defined $json;

my $xml = new XML::Simple;
# Decode the entire JSON
my $decoded = $xml->XMLin( $json );

# you'll get this (it'll print out); comment this when done.
#print Dumper $decoded;

foreach my $f ( @{$decoded->{root}{node}} ) {
  if ($f->{"agglomeration"}eq $agglomeration) {
	print $f->{"valeurIndice"} . " " . $f->{"SousIndiceO3"} . " " . $f->{"SousIndiceNO2"} ." ". $f->{"SousIndiceSO2"} . " " .$f->{"SousIndicePM10"} . "\n";
	my $payload=$f->{"valeurIndice"};
	if (isdigit($payload)) { `curl -s "http://$domo_ip:$domo_port/json.htm?type=command&param=udevice&idx=$dz_ind&nvalue=$payload"`; }
	$payload=$f->{"SousIndiceO3"};
	if (isdigit($payload)) { `curl -s "http://$domo_ip:$domo_port/json.htm?type=command&param=udevice&idx=$dz_o3&nvalue=$payload"`; }
	$payload=$f->{"SousIndiceNO2"};
	if (isdigit($payload)) { `curl -s "http://$domo_ip:$domo_port/json.htm?type=command&param=udevice&idx=$dz_no2&nvalue=$payload"`; }
	$payload=$f->{"SousIndiceSO2"};
	if (isdigit($payload)) { `curl -s "http://$domo_ip:$domo_port/json.htm?type=command&param=udevice&idx=$dz_so2&nvalue=$payload"`; }
	$payload=$f->{"SousIndicePM10"};
	if (isdigit($payload)) { `curl -s "http://$domo_ip:$domo_port/json.htm?type=command&param=udevice&idx=$dz_pm10&nvalue=$payload"`; }
  }
}
