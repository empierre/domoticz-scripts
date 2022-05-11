#!/usr/bin/perl
#
# Get eto from OpenSprinkler to a percentage domorticz
#
use v5.14;
use LWP::Simple;                # From CPAN
use JSON ;    # From CPAN
use File::Slurp;
use LWP::UserAgent;
use Crypt::SSLeay;
use Data::Dumper;               # Perl core module
use strict;                     # Good practice
use warnings;                   # Good practice
use utf8;
use Time::Piece;
use feature     qw< unicode_strings >;
 
# Create an HTTP client
my $ua = LWP::UserAgent->new;
$ua->agent('RasperryPiInMyHome/1.4 ');
 
my $trendsurl = "http://192.168.86.21:8080/jc?pw=e8d272ea8356c086759dff5297246840";

my $json = $ua->get( $trendsurl );
die "Could not get $trendsurl!" unless defined $json;
# Decode the entire JSON
my $decoded = JSON->new->utf8(0)->decode( $json->decoded_content );

#print Dumper($decoded);
my $payload=$decoded->{"wtdata"}->{"eto"}*1000;

print "sending $payload to DZ 1197\n";

`curl -s "http://192.168.86.28:8080/json.htm?type=command&param=udevice&idx=1134&svalue=$payload"&`;

