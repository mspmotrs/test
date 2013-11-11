package MSConfigUtil;
use strict;
use warnings;

require Exporter;
our @ISA = qw(Exporter);

# Exporting the saluta routine
our @EXPORT = qw(MS_XMLCheckParsing);
# Exporting the saluta2 routine on demand basis.
#our @EXPORT_OK = qw(saluta2);




# use ../../ as lib location
use FindBin qw($Bin);
use lib "$Bin/..";
use lib "$Bin/../cpan-lib";







sub MS_XMLCheckParsing
{
	my $MS_ConfigHash_ptr = shift;
	my $XML_content = shift;


		
	 # __DIE__ hooks may modify error messages
	{
		#local $SIG{'__DIE__'} = sub { (my $x = $_[0]) =~ s/foo/bar/g; die $x };
		#local $SIG{'__DIE__'} = sub { my $x = $_[0]; $x="MS: Errore di parsing XML\n".$x; die $x };
		local $SIG{'__DIE__'} = sub { 
										my $context = shift;
										my $x="[MS] Errore durante parsing XML: $context\n";
										$MS_ConfigHash_ptr->{OTRS_LogObject}->Log( Priority => 'error', Message => "$MS_ConfigHash_ptr->{log_prefix} $x");
										die $x; 
									};
		eval 
		{  
			local *STDOUT;
			open STDOUT, '>', '/dev/null' or die "can't redirect STDOUT to /dev/null $!";
		
			local *STDERR;
			open STDERR, '>', '/dev/null' or die "can't redirect STDERR to /dev/null $!";
		
			use XML::Parser;
			my $p1 = new XML::Parser(Style => 'Debug', ErrorContext => 3);
		
			$p1->parse($XML_content); #XML di cui fare il parsing
			#$p1->parsefile($config_file_name);
		};
		if($@)
		{
			#print "\nL'XML sembra malformato: esco...\n" ; #TODO
			$MS_ConfigHash_ptr->{OTRS_LogObject}->Log( Priority => 'error', Message => "$MS_ConfigHash_ptr->{log_prefix} L'XML sembra malformato... esco.");
			exit(1);
		}
		else
		{
			my @XMLStructure;
			my @XMLHash; # in OTRS lo chiamano cosi' anche se e' un array... bha'...

			print "\nIl file di configurazione sembra corretto...\n"; 

			@XMLStructure = $MS_ConfigHash_ptr->{OTRS_XMLObject}->XMLParse(String => $XML_content); 
			@XMLHash = $MS_ConfigHash_ptr->{OTRS_XMLObject}->XMLStructure2XMLHash(XMLStructure => \@XMLStructure);
		
		
			return \@XMLHash;
			#exit(0);
		}
	}	
    

}







1;