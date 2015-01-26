use strict;
use warnings;
use Test::More tests => 1;
use Net::Curl::Easy::FFI;

my $curl = curl_easy_init;
ok $curl, "curl = $curl";
curl_easy_cleanup $curl;
