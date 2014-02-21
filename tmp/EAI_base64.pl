#!/usr/bin/perl -w

use strict;
use warnings;






use MIME::Base64;



my $stringa = 'iuygcf7630r103r+0j0ì+o+l€#@•–¶][]][[[¶###@@@#¶¶¶¶¶]]]';

my $from_external = '';
my $from_internal = '';

open(B64,"| base64 |") || die "Failed: $!\n";

print B64 $stringa;

my $content = '';
while ( $content = <B64> ) 
{
  $from_external .= $content;
}
close(B64);



$from_internal = encode_base64($stringa);


print "\nEXTERNAL=".$from_external;
print "\nINTERNAL=".$from_internal;










