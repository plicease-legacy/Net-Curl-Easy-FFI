use strict;
use warnings;
use Test::More tests => 5;
use Net::Curl::Easy::FFI;

my $curl = curl_easy_init;

my $unescaped;

is do { $unescaped = curl_easy_unescape $curl, 'foo' }, 'foo', "foo=$unescaped";
is do { $unescaped = curl_easy_unescape $curl, 'foo', 0 }, 'foo', "foo=$unescaped";
is do { $unescaped = curl_easy_unescape $curl, 'foo', 2 }, 'fo', "foo=$unescaped";
is do { $unescaped = curl_easy_unescape $curl, 'foo%00bar' }, "foo\0bar", "foo=$unescaped";
is do { $unescaped = curl_easy_unescape $curl, 'foo%00bar', 9 }, "foo\0bar", "foo=$unescaped"; 
