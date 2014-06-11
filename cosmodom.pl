#!/usr/bin/perl
use v5.14;
use LWP::Simple;                # From CPAN
#use JSON qw( decode_json );     # From CPAN
use JSON ;    # From CPAN
use File::Slurp;
use LWP::UserAgent;
use Crypt::SSLeay;
use Data::Dumper;               # Perl core module
use strict;                     # Good practice
use warnings;                   # Good practice
use utf8;
use feature     qw< unicode_strings >;


my $COSM_API_KEY = '7W0c7m4H4Seb4kRIrI5NjQszYhD9IFVFKlmW7OHNvJqA5lyS';
my $COSM_FEED = "140510344";
my $feed = { 'version' => '1.0.0', 'datastreams' => [] };
 
# Create an HTTP client
my $ua = LWP::UserAgent->new;
$ua->agent('RasperryPiInMyShed/1.0 ');
 
 
#while (my ($address, $name) = each(%MAPPING)) {
#	my $temp = OW::get("/$address/temperature");
#	$temp =~ s/\s//g;
#	push(@{$feed->{'datastreams'}}, {'id' => $name, 'current_value' => $temp});
#}

my $trendsurl = "http://192.168.0.24:8080/json.htm?type=devices&filter=all&used=true&order=Name";

my $json = get( $trendsurl );
die "Could not get $trendsurl!" unless defined $json;
# Decode the entire JSON
my $decoded = JSON->new->utf8(0)->decode( $json );

my @results = @{ $decoded->{'result'} };
foreach my $f ( @results ) {
  if ($f->{"SwitchType"}) {
        #print $f->{"idx"} . " " . $f->{"Name"} . " " . $f->{"Status"} . "\n";
  } elsif ($f->{"Type"} eq "Group") {
        #print $f->{"idx"} . " " . $f->{"Name"} . " " . $f->{"Status"} . "\n";
  } else {
        my $te=$f->{"Data"};
        my $name=$f->{"Name"};
	next if $te=~/;/;
	next if $f->{"idx"}==3;

	my @tab=split(/,/,$te);
	foreach my $tem (@tab) {
		my ($temp,$unit)=($tem=~/(\d*.?\d*)(.*)/);
		$unit=~s/\s*//;
		$temp=~s/\s*//;
		my $nam;
		if ($te=~/,/) { $nam=$name.'_'.$unit; } else {$nam=$name;}
		$nam=~s/\s/_/;
		$nam=~s/\//_/;
		$nam=~s/%/P/;
		print "$nam/$temp/$unit\n";
		push(@{$feed->{'datastreams'}}, {'id' => $nam, 'current_value' => scalar($temp), 'units' => $unit});
	}
  }
}

 
# Get the temperature of the core
my $temp = read_file('/sys/class/thermal/thermal_zone0/temp') / 1000;
push(@{$feed->{'datastreams'}}, {'id' => 'pi-core', 'current_value' => $temp});

	# Create a HTTP request
	my $req = HTTP::Request->new(PUT => "https://api.xively.com/v2/feeds/$COSM_FEED");
	$req->header('X-ApiKey' => $COSM_API_KEY);
	$req->content_type('application/json');
	$req->content(encode_json($feed));
	 
	# Make the request
	my $res = $ua->request($req);
	unless ($res->is_success) {
		print STDERR $res->status_line, "\n";
		print STDERR $res->content, "\n";
	}

