use strict;
use warnings;
use Net::Curl::Easy::FFI;

my $curl = curl_easy_init;

curl_easy_setopt $curl, CURLOPT_URL, "http://perl.org";
curl_easy_setopt $curl, CURLOPT_FOLLOWLOCATION, 1;

my $res = curl_easy_perform $curl;
warn "curl_easy_perform failed: ", curl_easy_strerror($res)
  unless $res == CURLE_OK;

curl_easy_cleanup $curl;
