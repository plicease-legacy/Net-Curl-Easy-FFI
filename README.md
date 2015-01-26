# Net::Curl::Easy::FFI

Perl interface for curl\_easy\_\* functions

# SYNOPSIS

download to stdout:

    use Net::Curl::Easy::FFI;
    
    my $curl = curl_easy_init;
    
    curl_easy_setopt $curl, CURLOPT_URL, "http://perl.org";
    curl_easy_setopt $curl, CURLOPT_FOLLOWLOCATION, 1;
    
    my $res = curl_easy_perform $curl;
    warn "curl_easy_perform failed: ", curl_easy_strerror($res)
      unless $res == CURLE_OK;
    
    curl_easy_cleanup $curl;

escape/unescape URLs:

    use Net::Curl::Easy::FFI;
    
    my $curl = curl_easy_init;
    
    my $escaped = curl_easy_escape "<foo>";
    print "$escaped\n"; # %3Cfoo%3E
    
    my $unescaped = curl_easy_unescape "%3Cfoo%3D";
    print "$unescaped\n"; # <foo>
    
    curl_easy_cleanup $curl;

# DESCRIPTION

This module provides an interface for libcurl's "easy" interface.  It is 
different from the like named [Net::Curl::Easy](https://metacpan.org/pod/Net::Curl::Easy) in that it is 
implemented using FFI (See [FFI::Platypus](https://metacpan.org/pod/FFI::Platypus) for details) instead of XS 
and that it does not provide an object oriented interface, instead 
preferring to more closely mirror the libcurl interface.

# FUNCTIONS

## curl\_easy\_init

    my $curl = curl_easy_init;

Creates a CURL handle.  The CURL handle is not automatically free'd Make 
sure that you call ["curl\_easy\_cleanup"](#curl_easy_cleanup) when you are finished with it.

## curl\_easy\_cleanup

    curl_easy_cleanup $curl;

Free's the CURL handle.

## curl\_easy\_escape

    my $escaped = curl_easy_escape $string;
    my $escaped = curl_easy_escape $string, $length;

This function converts the given input string to an URL encoded string 
and returns that as a string. All input characters that are not a-z, 
A-Z, 0-9, '-', '.', '\_' or '~' are converted to their "URL escaped" 
version (`%NN` where NN is a two-digit hexadecimal number).

If the `$length` argument is set to 0 (zero), curl\_easy\_escape uses the 
C function `strlen` on the input `$string` to find out the size.  This 
means that if you have a null character (`"\0"`) in your string that 
you should explicitly provide the `$length` parameter unless you want 
the result truncated.  Example:

    my $escaped = curl_easy_escape "foo\0bar", length "foo\0bar";
    print "$escaped\n"; # prints "foo%00bar"

## curl\_easy\_unescape

    my $unescaped = curl_easy_unescape $string;
    my $unescaped = curl_easy_unescape $string, $length;

This function converts the given URL encoded input string to a "plain 
string" and returns the unescaped string.  All input characters that are 
URL encoded (`%NN` where NN is a two digit hexadecimal number) are 
converted to their binary versions.

If the length argument is set to 0 (zero), `curl_easy_unescape` will 
use the C function `strlen` on the input `$string` to find out the 
size.  Like ["curl\_easy\_escape"](#curl_easy_escape) if you have a null character in your 
string you should provide the `$length` argument, though it is hard to 
see a use case for having a null in an URL encoded string.

## curl\_version

    my $version_string = curl_version;

Returns a human readable string with the version number of libcurl and 
some of its important components (like OpenSSL).

# AUTHOR

Graham Ollis <plicease@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2015 by Graham Ollis.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
