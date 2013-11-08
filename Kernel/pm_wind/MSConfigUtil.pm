package MSConfigUtil;
use strict;
use warnings;

require Exporter;
our @ISA = qw(Exporter);

# Exporting the saluta routine
our @EXPORT = qw(saluta);
# Exporting the saluta2 routine on demand basis.
our @EXPORT_OK = qw(saluta2);




my %prova = (
   saluto => 'Ciao gente!'
);

sub saluta
{
   print "ciao";
   return \%prova;
}

sub saluta2
{
   print "ciao";
}


1;
