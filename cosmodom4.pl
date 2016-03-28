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
use Time::Piece;
use feature     qw< unicode_strings >;


my $COSM_API_KEY = '';
my $COSM_FEED = "";
my $feed = { 'version' => '1.0.0', 'datastreams' => [] };
my %list={};
 
# Create an HTTP client
my $ua = LWP::UserAgent->new;
$ua->agent('RasperryPiInMyHome/1.4 ');
 
my $trendsurl = "http://192.168.0.28:8080/json.htm?type=devices&filter=all&used=true&order=Name";

my $json = $ua->get( $trendsurl );
die "Could not get $trendsurl!" unless defined $json;
# Decode the entire JSON
my $decoded = JSON->new->utf8(0)->decode( $json->decoded_content );

my @results = @{ $decoded->{'result'} };
foreach my $f ( @results ) {
  if ($f->{"SwitchType"}) {
        #print $f->{"idx"} . " " . $f->{"Name"} . " " . $f->{"Status"} . $f->{"LastUpdate"}."\n";
	my $dt = Time::Piece->strptime($f->{"LastUpdate"},"%Y-%m-%d %H:%M:%S");
        my $name=$f->{"Name"};
	$name=~s/\s/_/;
	$name=~s/\s/_/;
	$name=~s/\//_/;
	$name=~s/%/P/;
	$name.="_E";
	my $bl=$f->{"Status"};my $rbl;
	if ($bl eq "On") { $rbl=1;} 
	elsif ($bl eq "Off") { $rbl=0;} 
	else { $rbl=$bl;} 
	#print "L0 $name $name/$rbl/".$dt->datetime."\n";
	$rbl=~s/ //;
	#push(@{$feed->{'datastreams'}}, {'id' => $name, 'current_value' => $rbl, 'datapoints' => { "at" => $dt->datetime, "value" => $rbl } });
	#push(@{$feed->{'datastreams'}}, {'id' => $name, 'current_value' => $rbl, "at" => $dt->datetime });
  } elsif ($f->{"Type"} eq "Group") {
        #print $f->{"idx"} . " " . $f->{"Name"} . " " . $f->{"Status"} . "\n";
  } else {
        #print $f->{"idx"} . " " . $f->{"Name"} . " " . $f->{"Data"} . "\n";
        my $te=$f->{"Data"};
        my $name=$f->{"Name"};
	#next if $te=~/;/;
	#next if $name=~/CM180/;
	#next if $name=~/RFXMeter/;
	next if $name=~/Evohome/;
	#next if $f->{"idx"}==131;
	next if $f->{"idx"}==3;

	my @tab;
	if ($te=~/;/) {
		@tab=split(/;/,$te);
			my $nam=$f->{"Name"};
			$nam=~s/\s/_/;
			$nam=~s/\//_/;
			$nam=~s/\ /_/g;
			$nam=~s/%/P/;
			#print "$nam $nam/$tab[0]/mm\n";
			print "R ".$nam."_rate/$tab[1]/mm\n";
			push(@{$feed->{'datastreams'}}, {'id' => $nam, 'current_value' => scalar($tab[0]), 'units' => "mm"});
			push(@{$feed->{'datastreams'}}, {'id' => $nam."_rate", 'current_value' => scalar($tab[1]), 'units' => "mm"});
	} else {
		@tab=split(/,/,$te);
		my $idx=0;
		foreach my $tem (@tab) {
			my ($temp,$unit)=($tem=~/(\-?\d*.?\d*)(.*)/);
			if ($tem=~/Total/) {
				($unit,$temp)=($tem=~/(Total): (\-?\d*.?\d*)/);
			}
			$idx++;
			$unit=~s/\s*//;
			$temp=~s/\s*//;
			my $nam;
			if ($name=~/CM180/){ 
				$nam=$name."_l".$idx;
				$unit="kWh";
			} elsif ($f->{"Type"} eq "RFXMeter") {
				if ($f->{"SubType"} eq "RFXMeter counter") {
					if ($idx==1) {$nam=$name."_last"; } else {$nam=$name."_counter";}
				}
			} elsif ($f->{"Type"} eq "Humidity") {
			        $temp=$f->{"Humidity"};
				$nam=$name;
				$unit="%";
			} else {
				if ($te=~/,/) { $nam=$name.'_'.$unit; } else {$nam=$name;}
			}
			$temp=~s/\s//g;
			$nam=~s/\s/_/g;
			$nam=~s/\//_/g;
			$nam=~s/\ /_/g;
			$nam=~s/\./_/g;
			$nam=~s/%/P/g;
			#if (length($nam)>30) {$nam=substr($nam,0,30);}
			if ($list{$nam}) {
				print "DUPL $nam $nam/$temp/$unit\n";
			} else {
				print "$nam $nam/$temp/$unit\n";
				$list{$nam}=1;
				push(@{$feed->{'datastreams'}}, {'id' => $nam, 'current_value' => scalar($temp), 'units' => $unit});
			}
			}
	}
	if ($f->{"BatteryLevel"}<100) {
        	my $bl=$f->{"BatteryLevel"};
		$bl=sprintf "%2.0f", $bl;
		my $nam=$name."_Battery";
		$nam=~s/\s/_/;
		$bl=~s/\s//;
		print "$nam/$bl/%\n";
		push(@{$feed->{'datastreams'}}, {'id' => $nam, 'current_value' => $bl, 'units' => '%'});
	
	}
  }
}

#print Dumper $feed;
 
# Get the temperature of the core
my $temp = read_file('/sys/devices/virtual/thermal/thermal_zone0/temp') / 1000;
$temp=sprintf "%2.3f", $temp;
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

