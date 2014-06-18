package Domo;
use Dancer ':syntax';
use File::Slurp;
use LWP::UserAgent;
use Crypt::SSLeay;
use utf8;
use Time::Piece;
use feature     qw< unicode_strings >;

our $VERSION = '0.1';

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

get '/devices' => sub {
	print "list all\n";

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


true;
