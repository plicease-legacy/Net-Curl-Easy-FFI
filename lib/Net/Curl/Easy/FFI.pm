package Net::Curl::Easy::FFI;

use strict;
use warnings;
use Net::Curl::Easy::FFI::constants;
use FFI::CheckLib qw( find_lib_or_die );
use FFI::Platypus::Declare
  qw( void string opaque int long ),
  [ 'off_t' => 'curl_off_t' ], # TODO: check on that
  [ 'int *' => 'int_p' ],
  [ opaque => 'CURL' ];
use Carp qw( croak );
use constant astring => 'astring';
use base qw( Exporter);


# ABSTRACT: Perl interface for curl_easy_* functions
# VERSION

=head1 SYNOPSIS

download to stdout:

# EXAMPLE: example/simple.pl

escape/unescape URLs:

 use Net::Curl::Easy::FFI;
 
 my $curl = curl_easy_init;
 
 my $escaped = curl_easy_escape "<foo>";
 print "$escaped\n"; # %3Cfoo%3E
 
 my $unescaped = curl_easy_unescape "%3Cfoo%3D";
 print "$unescaped\n"; # <foo>
 
 curl_easy_cleanup $curl;

=head1 DESCRIPTION

This module provides an interface for libcurl's "easy" interface.  It is 
different from the like named L<Net::Curl::Easy> in that it is 
implemented using FFI (See L<FFI::Platypus> for details) instead of XS 
and that it does not provide an object oriented interface, instead 
preferring to more closely mirror the libcurl interface.

By default this module exports all of the functions and constants that 
it implements.  You can explicitly export just the symbols that you 
want.

=cut

lib find_lib_or_die lib => "curl";

attach_cast opaque_to_string => opaque => 'string';

# CURL sometimes returns memory that it itself has
# malloc'd and needs to be freed using curl_free.
custom_type astring => {
  native_type => 'opaque',
  native_to_perl => sub {
    my $value = opaque_to_string($_[0]);
    _free($_[0]);
    $value;
  },
};

=head1 FUNCTIONS

=head2 curl_easy_init

 my $curl = curl_easy_init;

Creates a CURL handle.  The CURL handle is not automatically free'd Make 
sure that you call L</curl_easy_cleanup> when you are finished with it.

=head2 curl_easy_cleanup

 curl_easy_cleanup $curl;

Free's the CURL handle.

=head2 curl_easy_escape

 my $escaped = curl_easy_escape $string;
 my $escaped = curl_easy_escape $string, $length;

This function converts the given input string to an URL encoded string 
and returns that as a string. All input characters that are not a-z, 
A-Z, 0-9, '-', '.', '_' or '~' are converted to their "URL escaped" 
version (C<%NN> where NN is a two-digit hexadecimal number).

If the C<$length> argument is set to 0 (zero), curl_easy_escape uses the 
C function C<strlen> on the input C<$string> to find out the size.  This 
means that if you have a null character (C<"\0">) in your string that 
you should explicitly provide the C<$length> parameter unless you want 
the result truncated.  Example:

 my $escaped = curl_easy_escape "foo\0bar", length "foo\0bar";
 print "$escaped\n"; # prints "foo%00bar"

=head2 curl_easy_unescape

 my $unescaped = curl_easy_unescape $string;
 my $unescaped = curl_easy_unescape $string, $length;

This function converts the given URL encoded input string to a "plain 
string" and returns the unescaped string.  All input characters that are 
URL encoded (C<%NN> where NN is a two digit hexadecimal number) are 
converted to their binary versions.

If the length argument is set to 0 (zero), C<curl_easy_unescape> will 
use the C function C<strlen> on the input C<$string> to find out the 
size.  Like L</curl_easy_escape> if you have a null character in your 
string you should provide the C<$length> argument, though it is hard to 
see a use case for having a null in an URL encoded string.

=head2 curl_version

 my $version_string = curl_version;

Returns a human readable string with the version number of libcurl and 
some of its important components (like OpenSSL).

=cut

attach curl_easy_init     => []                      => CURL    => '';
attach curl_easy_cleanup  => [CURL]                  => void    => '$';
attach curl_easy_escape   => [CURL,string,int]       => astring => '$$;$';
attach curl_easy_perform  => [CURL]                  => int     => '$';
attach curl_easy_strerror => [int]                   => string  => '$';
attach [curl_easy_unescape => 
       '_easy_unescape' ] => [CURL,string,int,int_p] => opaque;
attach [curl_free =>
       '_free' ]          => [opaque]                => void    => '$';
attach curl_version       => []                      => string  => '';

attach [curl_easy_setopt => '_setopt_long'] =>
       [ CURL, int, long ] => int;
attach [curl_easy_setopt => '_setopt_string'] =>
       [ CURL, int, string ] => int;
attach [curl_easy_setopt => '_setopt_opaque'] =>
       [ CURL, int, opaque ] => int;
attach [curl_easy_setopt => '_setopt_off_t'] =>
       [ CURL, int, curl_off_t ] => int;

sub curl_easy_unescape ($$;$)
{
  my $len;
  my $ptr = _easy_unescape($_[0], $_[1], $_[2], \$len);
  return unless defined $ptr;
  unpack 'P'.$len, pack 'L!', $ptr;
}

sub curl_easy_setopt ($$$)
{
  my $opttype = $_[1] - $_[1] % CURLOPTTYPE_OBJECTPOINT;
  if($opttype == CURLOPTTYPE_LONG)
  { goto &_setopt_long }
  elsif($opttype == CURLOPTTYPE_OBJECTPOINT)
  {
    # OBJECTPOINT is used for both strings and
    # pointery stuff, so if you really want a
    # pointery thing, pass in a reference to
    # an opaque pointer.
    if(ref $_[2])
    {
      _setopt_opaque($_[0], $_[1], ${$_[2]});
    }
    else
    {
      goto &_setopt_string
    }
  }
  elsif($opttype == CURLOPTTYPE_FUNCTIONPOINT)
  { goto &_setopt_opaque }
  elsif($opttype == CURLOPTTYPE_OFF_T)
  { goto &_setopt_off_t }
  else
  { croak "invalid option: $_[1]" }
}

our @EXPORT = grep /^(curl_easy|CURL)/, keys %Net::Curl::Easy::FFI::;
push @EXPORT, 'curl_version';

1;
