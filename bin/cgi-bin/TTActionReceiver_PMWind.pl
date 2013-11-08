#!/usr/bin/perl -w

# --
# bin/cgi-bin/XXXXXXXXXX.pl - Accenture XXXXXXXX
# Copyright (C) 2013 MS - Accenture
# --
# $Id: XXXXXXXXX.pl,v 1.0 2013/09/24 10:00:00 tr Exp $
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

use strict;
use warnings;



## --- MS: questi path presuppongono che questo eseguibile si trova in <OTRS_path>bin/cgi-bin ---
# use ../../ as lib location
use FindBin qw($Bin);
use lib "$Bin/../..";
#use lib "$Bin/../../Kernel";
use lib "$Bin/../../Kernel/cpan-lib";

# use vars qw($VERSION @INC);
# $VERSION = qw($Revision: 1.88 $) [1];

# check @INC for mod_perl (add lib path for "require module"!)
push( @INC, "$Bin/../..", "$Bin/../../Kernel/cpan-lib" );



use Data::Dumper;





# ----------------- parsing XML ------------------

	use Kernel::Config;
	use Kernel::System::Encode;
	use Kernel::System::Log;
	use Kernel::System::Main;
	use Kernel::System::DB;

	use Kernel::System::XML;

	use Kernel::System::Time;
	use Kernel::System::Ticket;




	my $ConfigObject = Kernel::Config->new();
	my $EncodeObject = Kernel::System::Encode->new(
		ConfigObject => $ConfigObject,
	);
	my $LogObject = Kernel::System::Log->new(
		ConfigObject => $ConfigObject,
		EncodeObject => $EncodeObject,
	);
	my $MainObject = Kernel::System::Main->new(
		ConfigObject => $ConfigObject,
		EncodeObject => $EncodeObject,
		LogObject    => $LogObject,
	);
	my $DBObject = Kernel::System::DB->new(
		ConfigObject => $ConfigObject,
		EncodeObject => $EncodeObject,
		LogObject    => $LogObject,
		MainObject   => $MainObject,
	);
	
	
	
	my $TimeObject = Kernel::System::Time->new(
		ConfigObject => $ConfigObject,
		LogObject    => $LogObject,
	);
          





    my $XMLObject = Kernel::System::XML->new(
        ConfigObject => $ConfigObject,
        LogObject    => $LogObject,
        DBObject     => $DBObject,
        MainObject   => $MainObject,
        EncodeObject => $EncodeObject,
    );







#Hash che contiene le configurazioni lette dal file di config
my %MS_ConfigHash;
ConfigFileParsing();



sub ConfigFileParsing
{	


	# ------ apertura del file di config ------
	my $config_file_content = '';

	#ATTENZIONE: questo path suppone che questo eseguibile si trova in <OTRS_path>bin/cgi-bin/
	my $config_file_name = "$Bin/../../Kernel/pm_wind/config_pm_wind.conf";
	open(INGRESSO, "< $config_file_name") or die "\nNon riesco ad aprire il file $config_file_name \n";
	while(my $riga = <INGRESSO>) 
	{
		$config_file_content .= $riga;
	}
	close(INGRESSO);
	# ------ apertura del file di config (fine) ------



		
	 # __DIE__ hooks may modify error messages
	{
		#local $SIG{'__DIE__'} = sub { (my $x = $_[0]) =~ s/foo/bar/g; die $x };
		#local $SIG{'__DIE__'} = sub { my $x = $_[0]; $x="MS: Errore di parsing XML\n".$x; die $x };
		local $SIG{'__DIE__'} = sub { 
										my $context = shift;
										my $x="[MS] Errore durante parsing XML - $context\n"; 
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
		
			$p1->parse($config_file_content); #contenuto del file di config
			#$p1->parsefile($config_file_name);
		};
		if($@)
		{
			print "\nFile di configurazione malformato: mi tocca uscire...\n" ; #HTML
			exit(1);
		}
		else
		{
			my @XMLStructure;
			my @XMLHash; # in OTRS lo chiamano cosi' anche se e' un array... bha'...

			print "\nXML (apparentemente) corretto...\n"; 

			@XMLStructure = $XMLObject->XMLParse(String => $config_file_content); 
			@XMLHash = $XMLObject->XMLStructure2XMLHash(XMLStructure => \@XMLStructure);
		
			#use Data::Dumper;
			print Dumper(\@XMLHash );
		
			ConfigFileToConfigHash(\@XMLHash, \%MS_ConfigHash);
			
			print Dumper(\%MS_ConfigHash);
		
			exit(0);
		}
	}	
    

}






sub ConfigFileToConfigHash
{
	my $XMLHash_ptr = shift;
	my $ConfigHash_ptr = shift; #l'hash puntato conterra' le configurazione nella forma CAMPO => VALORE
	
	my $rit = 0;
	
	if(exists($XMLHash_ptr->[0]->{CONFIG_PM_WIND}[1]->{user_id}[1]->{Content}))
    {
    	$ConfigHash_ptr->{UserID} = $XMLHash_ptr->[0]->{CONFIG_PM_WIND}[1]->{user_id}[1]->{Content};
    	
    	# TODO: fare tutti i controlli del caso per verificare la validita' della conf (es: id numerico, id esistente, ecc.)
    }
    else #il tag NON esiste
    {
    	$rit = 1;	
		$ConfigHash_ptr->{ErrorCode} = 1;
		$ConfigHash_ptr->{ErrorDescription} = 'Errore di configurazione: manca in tag (user_id)';
    }
    

}





    