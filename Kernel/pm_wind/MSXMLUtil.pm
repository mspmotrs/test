package MSXMLUtil;
use strict;
use warnings;

require Exporter;
our @ISA = qw(Exporter);

# Exporting the saluta routine
our @EXPORT = qw(MS_XMLCheckParsing MS_HashToXMLString);
# Exporting the saluta2 routine on demand basis.
#our @EXPORT_OK = qw(saluta2);




# use ../../ as lib location
use FindBin qw($Bin);
use lib "$Bin/..";
use lib "$Bin/../cpan-lib";





# ----------------- Moduli custom necessari ------------------
use MSErrorUtil;









sub MS_SuppressNamaspaces
{
	my $hash_ptr = shift;
	my $recurse_level = shift;
	
	return if(!defined($recurse_level) or $recurse_level>4);
	#print "\nchiamato...";
	if(defined($hash_ptr ) and ref($hash_ptr) eq 'HASH') # ->{ns0:OTRS_API}   ->{OTRS_API}
	{
		#print "... su hash\n";
		
		my @key_list = keys(%{$hash_ptr});
		#print "KEYLIST = @key_list";
		#foreach my $key (%{$hash_ptr})
		for(my $kk=0; $kk<scalar(@key_list); $kk++)
		{
			my $key = $key_list[$kk];
			#print "\KEY = $key";
			
			if($key =~ m/^[^\:]+\:(.+)$/i)
			{

				$hash_ptr->{$1} = delete $hash_ptr->{$key};
				#print "AAAAAAA";
					
				if(ref($hash_ptr->{$1}) eq 'ARRAY' and defined($hash_ptr->{$1}->[1]) and ref($hash_ptr->{$1}->[1]) eq 'HASH')
				{
					#print "BBBBBB";
					$recurse_level++;
					MS_SuppressNamaspaces($hash_ptr->{$1}->[1], $recurse_level);
				}
			}
		}
	}
}







sub MS_XMLCheckParsing
{
	my $MS_ConfigHash_ptr = shift;
	my $XML_content = shift;

	my $rit = 1;

		
	 # __DIE__ hooks may modify error messages
	{
		#local $SIG{'__DIE__'} = sub { (my $x = $_[0]) =~ s/foo/bar/g; die $x };
		#local $SIG{'__DIE__'} = sub { my $x = $_[0]; $x="MS: Errore di parsing XML\n".$x; die $x };
		local $SIG{'__DIE__'} = sub { 
										my $context = shift;
										my $x="[MS] Errore durante parsing XML: $context\n";
										$MS_ConfigHash_ptr->{OTRS_LogObject}->Log( Priority => 'notice', Message => "$MS_ConfigHash_ptr->{log_prefix} $x");
										      
										#setto l'errore che verra' controllato nella subroutine a monte...
										MS_AssignInternalErrorCode( MS_WhoAmI(), 10, \$MS_ConfigHash_ptr->{Errors}->{InternalCode}, \$MS_ConfigHash_ptr->{Errors}->{InternalDescr});
										$MS_ConfigHash_ptr->{Errors}->{StopEsecution} = 1; # "prenoto" una exit

										$MS_ConfigHash_ptr->{OTRS_LogObject}->Log( Priority => 'notice', Message => "_MSFull_ XML DUMP:\n".$XML_content);
										
										#Non forzo la exit qui... lo faro' solo nella gestione dell'errore (modulo MSErrorUtil)
										#die $x;
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
			$MS_ConfigHash_ptr->{OTRS_LogObject}->Log( Priority => 'notice', Message => "$MS_ConfigHash_ptr->{log_prefix} L'XML sembra malformato... esco.");
      
			#setto l'errore che verra' controllato nella subroutine a monte...
			MS_AssignInternalErrorCode( MS_WhoAmI(), 20, \$MS_ConfigHash_ptr->{Errors}->{InternalCode}, \$MS_ConfigHash_ptr->{Errors}->{InternalDescr});
			$MS_ConfigHash_ptr->{Errors}->{StopEsecution} = 1; # "prenoto" una exit
			
			
			
			$MS_ConfigHash_ptr->{OTRS_LogObject}->Log( Priority => 'notice', Message => "_MSFull_ XML DUMP:\n".$XML_content);
										
			#Non forzo la exit qui... lo faro' solo nella gestione dell'errore (modulo MSErrorUtil)
			#exit(1);
		}
		else
		{
			my @XMLStructure;
			my @XMLHash; # in OTRS lo chiamano cosi' anche se e' un array... bha'...

			#print "\nIl file di configurazione sembra corretto...\n"; 

			@XMLStructure = $MS_ConfigHash_ptr->{OTRS_XMLObject}->XMLParse(String => $XML_content); 
			@XMLHash = $MS_ConfigHash_ptr->{OTRS_XMLObject}->XMLStructure2XMLHash(XMLStructure => \@XMLStructure);
			#@{$XMLHash_ptr} = $MS_ConfigHash_ptr->{OTRS_XMLObject}->XMLStructure2XMLHash(XMLStructure => \@XMLStructure);
		
			#se il log_level lo consente loggo la risposta
			if (!exists($MS_ConfigHash_ptr->{OTRS_ConfigObject}) or !defined($MS_ConfigHash_ptr->{OTRS_ConfigObject}))
			{
				$MS_ConfigHash_ptr->{OTRS_ConfigObject} = $MS_ConfigHash_ptr->{OTRS_XMLObject}->{ConfigObject};
			}
			
			my $logConf = $MS_ConfigHash_ptr->{OTRS_ConfigObject}->Get( 'PM_Wind_settings' );
			if(exists($logConf->{log_level}) and $logConf->{log_level} >2)
			{
				$MS_ConfigHash_ptr->{OTRS_LogObject}->Log( Priority => 'notice', Message => "_MSFull_ XML DUMP:\n".$XML_content);
			}
		
			my $ptr = \@XMLHash;
			MS_SuppressNamaspaces($ptr->[0], 0);
			return $ptr;
			#return \@XMLHash;
			#exit(0);
		}
	}	
    

}






1;
