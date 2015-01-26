use strict;
use warnings;
use Config::AutoConf;
use YAML::XS qw( LoadFile DumpFile );

my $prologue = <<EOF;
#include <curl/curl.h>
EOF

my $ac = Config::AutoConf->new;

$ac->check_prog_cc;

my @symbols = qw(
  CURLOPTTYPE_LONG
  CURLOPTTYPE_OBJECTPOINT
  CURLOPTTYPE_FUNCTIONPOINT
  CURLOPTTYPE_OFF_T
  CURLOPT_URL
  CURLOPT_FOLLOWLOCATION
  CURLE_OK
  CURLOPTTYPE_OBJECTPOINT
  CURLOPT_USERAGENT
  CURLOPT_COOKIEFILE
  CURLOPT_FILE
  CURLOPT_HEADERDATA
  CURLOPT_WRITEFUNCTION
  CURLOPT_WRITEDATA
  CURLOPT_VERBOSE
);

my $cache = eval { LoadFile("config.yml") } || {};

foreach my $symbol (@symbols)
{
  next if defined $cache->{$symbol};
  next unless $ac->check_decl($symbol, { prologue => $prologue });
  my $value = $ac->compute_int($symbol, { prologue => $prologue });
  #print $fh "use constant $symbol => $value;\n";
}

mkdir 'lib/Net/Curl/Easy/FFI'
  unless -d 'lib/Net/Curl/Easy/FFI';

open my $fh, '>', 'lib/Net/Curl/Easy/FFI/constants.pm';

print $fh <<EOF;
package
  Net::Curl::Easy::FFI;
use strict; use warnings;
EOF

foreach my $symbol (sort { $cache->{$a} <=> $cache->{$b} || $a cmp $b } keys %$cache)
{
  my $value = $cache->{$symbol};
  printf $fh "use constant %-30s => %8d;\n", $symbol, $value;
}

print $fh <<EOF;
1;
EOF
close $fh;

DumpFile("config.yml", $cache);
