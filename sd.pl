use LWP::UserAgent;
use JSON;
use strict;
use warnings;
my $ua = LWP::UserAgent->new;
my $SENSE_API_KEY = 'JqVA7G4EyOp-7e5BG1riJQ';

&SendToSenSe(19,54650);
&SendToSenSe(51,54651);

sub SendToSenSe {
       # Get parameters
       my $value = $_[0];
       # Remove the newline....
       chomp $value;
       my $feed_id = $_[1];
       chomp $feed_id;
       my %datalist = ('feed_id' =>  $feed_id, 'value'=>  $value );
       my $json = encode_json \%datalist;
       #print $json, "\n";
       # Create a request
       my $req = HTTP::Request->new(POST => "http://api.sen.se/events/?sense_key=".$SENSE_API_KEY);
       $req->content_type('application/json');
       $req->content($json);
       # Pass request to the user agent and get a response back
       my $res = $ua->request($req);
       # Check the outcome of the response
       if ($res->is_success) {
           return $res->content, "\n";
       }
       else {
       return $res->status_line, "\n";
       }
}
sub GetFromSenSe {
       my $feed_id = $_[0];
       # Create the request
       my $req = HTTP::Request->new(GET => "http://api.sen.se/feeds/$feed_id/last_event/?sense_key=".$SENSE_API_KEY);
       $req->content_type('application/json');
       #$req->content($json);
       # Pass request to the user agent and get a response back
       my $res = $ua->request($req);
       # Check the outcome of the response
       if ($res->is_success) {
           return $res->content, "\n";
       }
       else {
       return $res->status_line, "\n";
       }
}
