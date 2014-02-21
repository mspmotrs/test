#!/usr/bin/perl -w

use strict;
use warnings;




## --- MS: questi path presuppongono che questo eseguibile si trova in <OTRS_path>bin/cgi-bin ---
# use ../../ as lib location
use FindBin qw($Bin);
use lib "$Bin/../..";
use lib "$Bin/../../Kernel/pm_wind"; #MS: per i miei moduli custom
use lib "$Bin/../../Kernel/cpan-lib";

# use vars qw($VERSION @INC);
# $VERSION = qw($Revision: 1.88 $) [1];

# check @INC for mod_perl (add lib path for "require module"!)
push( @INC, "$Bin/../..", "$Bin/../../Kernel/cpan-lib" , "$Bin/../../Kernel/pm_wind" ); #MS: compresi i miei moduli custom



#----------------------------------------------------------






# ----------------- Moduli custom necessari ------------------
#use MSErrorUtil;
#use MSConfigUtil;
#use MSHttpUtil;
#use MSXMLUtil;
use MSRequestToWindUtil;
#use MSResponseFromWindUtil;


# ----------------- Moduli custom necessari ------------------
use MSErrorUtil;











# ----------------- Inizializzazione oggetti OTRS ------------------

	use Kernel::Config;
	use Kernel::System::Encode;
	use Kernel::System::Log;
	use Kernel::System::Main;
	use Kernel::System::DB;

	use Kernel::System::XML;

	use Kernel::System::Time;
	use Kernel::System::Ticket;




	my $MS_ConfigObject = Kernel::Config->new();
	my $MS_EncodeObject = Kernel::System::Encode->new(
		ConfigObject => $MS_ConfigObject,
	);
	my $MS_LogObject = Kernel::System::Log->new(
		ConfigObject => $MS_ConfigObject,
		EncodeObject => $MS_EncodeObject,
	);
	my $MS_MainObject = Kernel::System::Main->new(
		ConfigObject => $MS_ConfigObject,
		EncodeObject => $MS_EncodeObject,
		LogObject    => $MS_LogObject,
	);
	my $MS_DBObject = Kernel::System::DB->new(
		ConfigObject => $MS_ConfigObject,
		EncodeObject => $MS_EncodeObject,
		LogObject    => $MS_LogObject,
		MainObject   => $MS_MainObject,
	);
	
	
	
	my $MS_TimeObject = Kernel::System::Time->new(
		ConfigObject => $MS_ConfigObject,
		LogObject    => $MS_LogObject,
	);
          


    my $MS_TicketObject = Kernel::System::Ticket->new(
        ConfigObject => $MS_ConfigObject,
        LogObject    => $MS_LogObject,
        DBObject     => $MS_DBObject,
        MainObject   => $MS_MainObject,
        TimeObject   => $MS_TimeObject,
        EncodeObject => $MS_EncodeObject,
        #GroupObject  => $GroupObject,              # if given
        #CustomerUserObject => $CustomerUserObject, # if given
        #QueueObject        => $QueueObject,        # if given
    );



						

						
		my $MS_XMLObject = Kernel::System::XML->new(
																	ConfigObject => $MS_ConfigObject,
																	LogObject    => $MS_LogObject,
																	DBObject     => $MS_DBObject,
																	MainObject   => $MS_MainObject,
																	EncodeObject => $MS_EncodeObject,
															  );



my $TicketHash_ptr = {};
#$TicketHash_ptr->{ResponseHash} = {};

$TicketHash_ptr->{OTRS_XMLObject} = $MS_XMLObject;
$TicketHash_ptr->{OTRS_ConfigObject} = $MS_ConfigObject;
$TicketHash_ptr->{OTRS_LogObject} = $MS_LogObject;
$TicketHash_ptr->{OTRS_DBObject} = $MS_DBObject;
$TicketHash_ptr->{OTRS_MainObject} = $MS_MainObject;
$TicketHash_ptr->{OTRS_EncodeObject} = $MS_EncodeObject;
$TicketHash_ptr->{OTRS_TicketObject} = $MS_TicketObject;




my $RequestType = 'CREATE';
$TicketHash_ptr->{ResponseHash}->{ResponseContent} = '<?xml version="1.0" encoding="UTF-8"?>
<ns0:OTRS_API xmlns:ns0="http://www.tibco.com/schemas/OTTM/EnterpriseServices/InfrastrutureObject/Schemas/CommonSchemas/OTTM/TroubleTicket_OTRS.xsd">
    <ns0:TicketRequest>
        <ns0:NotifyUpdate xmlns:ns0="http://www.tibco.com/schemas/OTTM/EnterpriseServices/InfrastrutureObject/Schemas/CommonSchemas/OTTM/TroubleTicket_OTRS.xsd">
            <ns0:Header>
                <SourceChannel>WIND</SourceChannel>
                <DestinationChannel>OTRS</DestinationChannel>
                <TimeStamp>2014-01-28T14:41:03.655+01:00</TimeStamp>
                <TransactionId>TI1390916463655</TransactionId>
                <BusinessId>BI1390916463655</BusinessId>
            </ns0:Header>
            <Body>
                <TicketID>2014012710000019</TicketID>
                <TickedIDWind>PTT1390900815562</TickedIDWind>
                <Action>PRESA IN CARICO</Action>
                <Status>IN LAVORAZIONE</Status>
                <priority>3</priority>
                <CategoryTT>TMS.DISPATCHING SGSN</CategoryTT>
                <AmbitoTT>ALTRO</AmbitoTT>
                <TimestampTT>2014-01-28T14:41:03</TimestampTT>
                <Causale/>
            </Body>
        </ns0:NotifyUpdate>
    </ns0:TicketRequest>
</ns0:OTRS_API>';



















# ----------------- Attiva/disattiva debug per sviluppo ------------------
my $MS_DEBUG = 1; # 0 -> disattivato, 1 -> attivato











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
										#$MS_ConfigHash_ptr->{OTRS_LogObject}->Log( Priority => 'notice', Message => "$MS_ConfigHash_ptr->{log_prefix} $x");
										 
										 print  $x;   
										#setto l'errore che verra' controllato nella subroutine a monte...
										#MS_AssignInternalErrorCode( MS_WhoAmI(), 10, \$MS_ConfigHash_ptr->{Errors}->{InternalCode}, \$MS_ConfigHash_ptr->{Errors}->{InternalDescr});
										#$MS_ConfigHash_ptr->{Errors}->{StopEsecution} = 1; # "prenoto" una exit

										#$MS_ConfigHash_ptr->{OTRS_LogObject}->Log( Priority => 'notice', Message => "_MSFull_ XML DUMP:\n".$XML_content);
										
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
			#$MS_ConfigHash_ptr->{OTRS_LogObject}->Log( Priority => 'notice', Message => "$MS_ConfigHash_ptr->{log_prefix} L'XML sembra malformato... esco.");
      
			#setto l'errore che verra' controllato nella subroutine a monte...
			#MS_AssignInternalErrorCode( MS_WhoAmI(), 20, \$MS_ConfigHash_ptr->{Errors}->{InternalCode}, \$MS_ConfigHash_ptr->{Errors}->{InternalDescr});
			#$MS_ConfigHash_ptr->{Errors}->{StopEsecution} = 1; # "prenoto" una exit
			
			print "Muoio nell'if che intercetta l'errore...";
			
			
			#$MS_ConfigHash_ptr->{OTRS_LogObject}->Log( Priority => 'notice', Message => "_MSFull_ XML DUMP:\n".$XML_content);
										
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
				print "Dovrei fare il dumpe dell'XML...";
				#$MS_ConfigHash_ptr->{OTRS_LogObject}->Log( Priority => 'notice', Message => "_MSFull_ XML DUMP:\n".$XML_content);
			}
		
			my $ptr = \@XMLHash;
			MS_SuppressNamaspaces($ptr->[0], 0);
			return \@XMLHash;
			#exit(0);
		}
	}	
    

}






sub MS_ResponseToResponseHash
{
	my $TicketHash_ptr = shift;
	my $XMLHash_ptr = shift;

	
	#if ($MS_DEBUG)
	#{
	#	use Data::Dumper;
	#	print "\n".Dumper($XMLHash_ptr)."\n";
	#}
	
	
	my $rootTag = $XMLHash_ptr->[0]->{OTRS_API}[1]->{TicketResponse}[1];
	if (exists($rootTag->{CreateTTOutput}))
	{
		$rootTag = $rootTag->{CreateTTOutput}[1];
	}
	elsif (exists($rootTag->{NotifyTTOutput}))
	{
		$rootTag = $rootTag->{NotifyTTOutput}[1];
	}
	elsif (exists($rootTag->{UpdateTTOutput}))
	{
		$rootTag = $rootTag->{UpdateTTOutput}[1];
	}
	
	my $rootTagHeader = $rootTag->{Header}[1];
	#my $rootTagBody = $rootTag->{ResultStatus}[1];
	my $rootTagBody = $rootTag->{Response}[1];
	
	my $ResponseHash_prt = $TicketHash_ptr->{ResponseHash};
	$ResponseHash_prt->{Header} = {};
	#$ResponseHash_prt->{ResultStatus} = {};
	$ResponseHash_prt->{Response} = {};
	
	my $header = $ResponseHash_prt->{Header};
	#my $body = $ResponseHash_prt->{ResultStatus};
	my $body = $ResponseHash_prt->{Response};
	
	
	
	foreach my $key (keys(%{$rootTagHeader}))
	{	
		$header->{$key} = $rootTagHeader->{$key}[1]->{Content} if(exists($rootTagHeader->{$key}) and ref($rootTagHeader->{$key}) eq 'ARRAY' and exists($rootTagHeader->{$key}[1]->{Content}));
	}
	
	foreach my $key (keys(%{$rootTagBody}))
	{	
		$body->{$key} = $rootTagBody->{$key}[1]->{Content} if(exists($rootTagBody->{$key}) and ref($rootTagBody->{$key}) eq 'ARRAY' and exists($rootTagBody->{$key}[1]->{Content}));
	}
}





sub MS_CheckResponseFromWind
{
	my $TicketHash_ptr = shift;
	my $RequestType = shift; #CREATE, UPDATE, NOTIFY
	
	my $rit = 0;
	
	my $ResponseHash_ptr = $TicketHash_ptr->{ResponseHash};
	
	#if (defined($TicketHash_ptr) and exists($ResponseHash_ptr->{Header}) and exists($ResponseHash_ptr->{ResultStatus}) )
	if (defined($TicketHash_ptr) and exists($ResponseHash_ptr->{Header}) and exists($ResponseHash_ptr->{Response}) )
	{
		my $TransactionId = $TicketHash_ptr->{RequestHash}->{HEADER}->{TransactionId};
	
			#debug
			print "\nYYY1\n" if($MS_DEBUG);		
		
		if ($MS_DEBUG or ( exists($ResponseHash_ptr->{Header}->{TransactionId}) and ($TransactionId eq $ResponseHash_ptr->{Header}->{TransactionId})  ) ) #quando sono in debug ignoro il transactionID
		{
			
			#debug
			print "\nYYY2\n" if($MS_DEBUG);			
			
			#if (exists($ResponseHash_ptr->{ResultStatus}->{StatusCode}) )
			if (exists($ResponseHash_ptr->{Response}->{ReturnCode}) )
			{
				#if ($ResponseHash_ptr->{ResultStatus}->{StatusCode} == 0 )
				if ($ResponseHash_ptr->{Response}->{ReturnCode} == 0 )
				{
					if ($RequestType =~ m/^CREATE$/i)
					{
						#if(exists($ResponseHash_ptr->{ResultStatus}->{TicketID}) )
						if(exists($ResponseHash_ptr->{Response}->{idTT}) )
						{
							#$ResponseHash_ptr->{ResultStatus}->{TicketID} = $ResponseHash_ptr->{ResultStatus}->{idTT}; #legacy
							$ResponseHash_ptr->{Response}->{TicketID} = $ResponseHash_ptr->{Response}->{idTT}; #legacy
							
							$ResponseHash_ptr->{ResponseErrorCode} = 0;
							$ResponseHash_ptr->{ResponseErrorMessage} = '';
							$rit = 1;
						}
						else
						{
							$ResponseHash_ptr->{ResponseErrorCode} = 6; 
							$ResponseHash_ptr->{ResponseErrorMessage} = 'Response ad una request di CREATE priva del campo TicketID.';
						}
						
					}
					elsif($RequestType =~ m/^UPDATE$/i)
					{
						#if(exists($ResponseHash_ptr->{ResultStatus}->{Status}) )
						if(exists($ResponseHash_ptr->{Response}->{status}) )
						{
							$ResponseHash_ptr->{Response}->{Status} = $ResponseHash_ptr->{Response}->{status}; #legacy
							
							$ResponseHash_ptr->{ResponseErrorCode} = 0;
							$ResponseHash_ptr->{ResponseErrorMessage} = '';
							$rit = 1; #tutto ok
						}
						else
						{
							$ResponseHash_ptr->{ResponseErrorCode} = 5; 
							$ResponseHash_ptr->{ResponseErrorMessage} = 'Response ad una request di UPDATE priva del campo Status.';
						}
					}
					else #notify
					{
						$ResponseHash_ptr->{ResponseErrorCode} = 0;
						$ResponseHash_ptr->{ResponseErrorMessage} = '';
						$rit = 1; #tutto ok
					}
				}
				else
				{
					#if(exists($ResponseHash_ptr->{ResultStatus}->{ErrorMessage})  and exists($ResponseHash_ptr->{ResultStatus}->{ErrorDescription}) )
					if(exists($ResponseHash_ptr->{Response}->{ErrorMessage})  and exists($ResponseHash_ptr->{Response}->{ErrorDescription}) )
					{
						#$ResponseHash_ptr->{ResponseErrorCode} = $ResponseHash_ptr->{ResultStatus}->{ErrorMessage}; 
						#$ResponseHash_ptr->{ResponseErrorMessage} = $ResponseHash_ptr->{ResultStatus}->{ErrorDescription};
						$ResponseHash_ptr->{ResponseErrorCode} = $ResponseHash_ptr->{Response}->{ErrorMessage}; 
						$ResponseHash_ptr->{ResponseErrorMessage} = $ResponseHash_ptr->{Response}->{ErrorDescription};
					}
					else
					{
						$ResponseHash_ptr->{ResponseErrorCode} = 4; 
						$ResponseHash_ptr->{ResponseErrorMessage} = 'Response da Wind segnala errore ma manca dettaglio (ErrorMessage e ErrorDescription)';
					}
				}
			}
			else
			{
				$ResponseHash_ptr->{ResponseErrorCode} = 3; 
				$ResponseHash_ptr->{ResponseErrorMessage} = 'StatusCode assente nella Response!';
			}
			
		}
		else
		{
			$ResponseHash_ptr->{ResponseErrorCode} = 2; 
			$ResponseHash_ptr->{ResponseErrorMessage} = 'TransactionId della Response da EAI/Wind diverso da quello della Request';
		}
		
	}
	
	return $rit;
}


















use Data::Dumper;


my $XMLHash_ptr = MS_XMLCheckParsing($TicketHash_ptr, $TicketHash_ptr->{ResponseHash}->{ResponseContent});


print "\n\nXMLHash_ptr:\n".Dumper(\$XMLHash_ptr);

MS_ResponseToResponseHash($TicketHash_ptr, $XMLHash_ptr) ;

print "\n\nResponseHash:\n".Dumper($TicketHash_ptr->{ResponseHash});
print "\n\nRequestHash:\n".Dumper($TicketHash_ptr->{RequestHash});

my $response_result = MS_CheckResponseFromWind($TicketHash_ptr, $RequestType);




print $response_result;






