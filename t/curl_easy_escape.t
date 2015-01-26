use strict;
use warnings;
use Test::More tests => 5;
use Net::Curl::Easy::FFI;

my $curl = curl_easy_init;

my $escaped;

is do { $escaped = curl_easy_escape $curl, 'foo' },    'foo', "foo=$escaped";
is do { $escaped = curl_easy_escape $curl, 'foo', 0 }, 'foo', "foo=$escaped";
is do { $escaped = curl_easy_escape $curl, 'foo', 2 }, 'fo', "foo=$escaped";
is do { $escaped = curl_easy_escape $curl, "foo\0bar", 7 }, 'foo%00bar', "foo\\0bar=$escaped";
is do { $escaped = curl_easy_escape $curl, "foo\0bar" }, 'foo', "foo\\0bar=$escaped";

curl_easy_cleanup $curl;
