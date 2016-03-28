#!/usr/bin/perl -w
#use strict;
#use warnings;
use XML::Mini::Document;
use Data::Dumper;
#Customize below
my $IP='192.168.0.25';
my $PORT='88';
my $CAM_LOGIN='';
my $CAM_PASS='';
#Do not touch nothing below
my $xml = `curl -s "http://$IP:$PORT/cgi-bin/CGIProxy.fcgi?cmd=getMotionDetectConfig&usr=$CAM_LOGIN&pwd=$CAM_PASS" `;

my $xml_doc = XML::Mini::Document->new();
$xml_doc->parse($xml);
my $test_data = $xml_doc->toHash();

my $url_head="curl -s \"http://$IP:$PORT/cgi-bin/CGIProxy.fcgi?cmd=setMotionDetectConfig";
my $url_tail="&usr=$CAM_LOGIN&pwd=$CAM_PASS\"";


#print Dumper($test_data);
#print $test_data->{'CGI_Result'}->{'isEnable'};

#my $linkage=$ARGV[0] ||$test_data->{'CGI_Result'}->{'linkage'};
my $linkage=$ARGV[0] ||0;

my $url_body="&isEnable=".$test_data->{'CGI_Result'}->{'isEnable'}."&linkage=".$linkage."&snapInterval=".$test_data->{'CGI_Result'}->{'snapInterval'}."&sensitivity=".$test_data->{'CGI_Result'}->{'sensitivity'}."&triggerInterval=".$test_data->{'CGI_Result'}->{'triggerInterval'} ;

foreach my $i (0..6) {
	$url_body.="&schedule$i=".$test_data->{'CGI_Result'}->{"schedule$i"};
}
foreach my $i (0..9) {
	$url_body.="&area$i=".$test_data->{'CGI_Result'}->{"area$i"};
}
my $url=$url_head.$url_body.$url_tail;

`$url`;
#print $url;


