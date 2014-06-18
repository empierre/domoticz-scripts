package Domo;
use Dancer ':syntax';
use File::Slurp;
use LWP::UserAgent;
use Crypt::SSLeay;
use utf8;
use Time::Piece;
use feature     qw< unicode_strings >;
use JSON;

our $VERSION = '0.1';
set warnings => 1;

set serializer => 'JSON'; 
prefix undef;

get '/' => sub {
    template 'index';
};

get '/rooms' => sub {
       #Room list
  return {"rooms" => [ { "id"=> "noroom", "name"=> "noroom" }]};
};

get '/system' => sub {
 return {"id"=> "01:02:03:04:05:06","apiversion"=> 1};
};


get '/devices/:deviceId/action/:actionName/:actionParam?' => sub {
my $deviceId = params->{deviceId};
my $actionName = params->{actionName};
my $actionParam = params->{actionParam}||"";

if ($actionName eq 'setStatus') {
        #setStatus	0/1
	my $action;
	if ($actionParam eq 0) {
		$action="Off";
	} else {
		$action="On";
	}
	my $url="http://192.168.0.24:8080/json.htm?type=command&param=switchlight&idx=$deviceId&switchcmd=$action&level=0&passcode=";
	my $browser = LWP::UserAgent->new;
	my $response = $browser->get($url);
	if ($response->is_success){ 
		return { success => true};
	} else {
		status 'error';
		return { success => false, errormsg => $response->status_line};
	}
} elsif ($actionName eq 'setArmed') {
	#setArmed	0/1
	status 'error';
	return { success => false, errormsg => "not implemented"};
} elsif ($actionName eq 'setAck') {
	#setAck	
	status 'error';
	return { success => false, errormsg => "not implemented"};
} elsif ($actionName eq 'setLevel') {
	#setLevel	0-100
	#/json.htm?type=command&param=switchlight&idx=&switchcmd=Set%20Level&level=6
	return { success => true};
} elsif ($actionName eq 'stopShutter') {
	#stopShutter
	status 'error';
	return { success => false, errormsg => "not implemented"};
} elsif ($actionName eq 'pulseShutter') {
	#pulseShutter	up/down
	status 'error';
	return { success => false, errormsg => "not implemented"};
} elsif ($actionName eq 'launchScene') {
	#launchScene
	#/json.htm?type=command&param=switchscene&idx=&switchcmd=
	return { success => true};
} elsif ($actionName eq 'setChoice') {
	#setChoice string
	status 'error';
	return { success => false, errormsg => "not implemented"};
    } else {
        status 'not_found';
        return "What?";
   }
};

get '/devices' => sub {
	my $feed={ "devices" => []};
	my $trendsurl = "http://192.168.0.24:8080/json.htm?type=devices&filter=all&used=true&order=Name";
	my $ua = LWP::UserAgent->new();
	$ua->agent("Some/string");
	my $json = $ua->get( $trendsurl );
	warn "Could not get $trendsurl!" unless defined $json;
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
			#print "L0 $name/$rbl/".$dt->datetime."\n";

			my $feeds={"id" => $f->{"idx"}, "name" => $name, "type" => "DevSwitch", "room" => "noroom", params =>[]};
			push (@{$feeds->{'params'}}, {"key" => "Status", "value" =>$bl} );
			push (@{$feed->{'devices'}}, $feeds );
		};

	};

	return($feed);
	return { success => true};
};

true;
