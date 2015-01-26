use strict;
use warnings;
use Test::More tests => 1;
use Net::Curl::Easy::FFI;

my $version = curl_version;

ok $version, "version = $version";

diag '';
diag '';
diag '';

foreach my $item (split /\s+/, $version)
{
  diag "  $item";
}

diag '';
diag '';

