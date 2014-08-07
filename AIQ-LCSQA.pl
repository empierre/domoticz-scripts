#!/usr/bin/perl
use v5.14;
use LWP::Simple;                # From CPAN
use XML::Simple;                # From CPAN
use strict;                     # Good practice
use warnings;                   # Good practice
use utf8;    
use feature     qw< unicode_strings >;

my $trendsurl = " http://www.lcsqa.org/surveillance/indices/prevus/jour/xml/";

my $json = get( $trendsurl );
die "Could not get $trendsurl!" unless defined $json;

my $xml = new XML::Simple;
# Decode the entire JSON
my $decoded = $xml->XMLin( $json );

# you'll get this (it'll print out); comment this when done.
#print Dumper $decoded;

foreach my $f ( @{$decoded->{node}} ) {
  if ($f->{"agglomeration"}eq "PARIS") {
	print $f->{"valeurIndice"} . " " . $f->{"SousIndiceO3"} . " " . $f->{"SousIndiceNO2"} ." ". $f->{"SousIndiceSO2"} . " " .$f->{"SousIndicePM10"} . "\n";
	my $payload=$f->{"valeurIndice"};
	`curl -s "http://192.168.0.24:8080/json.htm?type=command&param=udevice&idx=211&nvalue=$payload"`;
  }
}
