#!/usr/bin/perl
use v5.14;
use LWP::Simple;                # From CPAN
use JSON qw( decode_json );     # From CPAN
use Data::Dumper;               # Perl core module
use strict;                     # Good practice
use warnings;                   # Good practice
use utf8;    
use feature     qw< unicode_strings >;


my $trendsurl = "http://192.168.0.24:8080/json.htm?type=devices&filter=all&used=true&order=Name";
my %IP=(39=>'192.168.0.23',
	40=>'192.168.0.22',
	10=>'192.168.0.25');

my $json = get( $trendsurl );
die "Could not get $trendsurl!" unless defined $json;

# Decode the entire JSON
my $decoded = JSON->new->utf8(0)->decode( $json );

my @results = @{ $decoded->{'result'} };

my @tab;
foreach my $f ( @results ) {
  if ($f->{"SwitchType"}) {
	$tab[$f->{"idx"}]=$f->{"Status"};
  }
}	
	


foreach my $k (keys %IP) {
	my $ip=$IP{$k};
	my $res=system("sudo ping $ip -w 3 2>&1 > /dev/null"); 
print "-->".$k." ".$res." ".$tab[$k]."\n";	
	if (($res==0)&&($tab[$k] eq 'Off')) {
		print "$k is On\n";
		`curl -s "http://192.168.0.24:8080/json.htm?type=command&param=switchlight&idx=$k&switchcmd=On"`; 
	} elsif (($res!=0)&&($tab[$k] eq 'On')) {
		print "$k is Off\n";
		`curl -s "http://192.168.0.24:8080/json.htm?type=command&param=switchlight&idx=$k&switchcmd=Off"`; 

	} else {
		print "do nothing: $k is ".$tab[$k]."\n";
	
	}
}


