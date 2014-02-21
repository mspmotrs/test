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
use MSErrorUtil;
use MSConfigUtil;
use MSHttpUtil;
use MSRequestFromWindUtil;
use MSResponseToWindUtil;
use MSRequestFromWindActionsUtil;

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



my %MS_ConfigHash = (
OTRS_XMLObject => $MS_XMLObject,
OTRS_ConfigObject => $MS_ConfigObject,
OTRS_LogObject => $MS_LogObject,
OTRS_DBObject => $MS_DBObject,
OTRS_MainObject => $MS_MainObject,
OTRS_EncodeObject => $MS_EncodeObject,
OTRS_TicketObject => $MS_TicketObject,
);


$MS_ConfigHash{RequestHash} = {
							RequestTypeCREATE => 'CREATE',
							RequestTypeUPDATE => 'UPDATE',
							RequestTypeNOTIFY => 'NOTIFY',
							RequestType => '', #CREATE, UPDATE, NOTIFY --> RequestTypeCREATE, RequestTypeUPDATE, RequestTypeNOTIFY
							RequestContent => '', #il contenuto della request cosi' come arriva al server
							RequestErrorCode => 0, # 0 = tutto ok 
							RequestErrorDescr => '',
							
							TicketID_is_a_TN => 1, #ad 1 se con Wind scambiamo il TN del ticket invece del suo ID
};



# my $RequestType = 'CREATE';
$MS_ConfigHash{RequestHash}->{RequestContent} = '<?xml version="1.0" encoding="UTF-8"?>
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







use Data::Dumper;

	#provo a fare il parsing della Request...
	MS_RequestParsing(\%MS_ConfigHash);

print "\n\nRequestHash:\n".Dumper(\$MS_ConfigHash{RequestHash});


	#Verifico se esiste qualche errore relativo al parsing della Request
	if ($MS_ConfigHash{RequestHash}->{RequestErrorCode} != 0)
	{
		print "\nerrore 1...";
		MS_SendResponseToWindOnBadRequestAndTerminate(\%MS_ConfigHash);
	}
	
	
	
	# Controllo eventuali errori semantici nella Request
	my $semantic_rit = MS_CheckRequestSemantic(\%MS_ConfigHash); # Ritorna 1 se OK, 0 se KO
	
	#Verifico se esiste qualche errore relativo alla semantica della Request
	if ($MS_ConfigHash{RequestHash}->{RequestErrorCode} != 0 or !$semantic_rit) 
	{
		print "\nerrore 2...";
		MS_SendResponseToWindOnBadRequestAndTerminate(\%MS_ConfigHash);
	}
	

	#ATTENZIONE: qui non abilito le azioni su OTRS
	#my $actionResult = MS_do_action(\%MS_ConfigHash); # Ritorna 1 se OK, 0 se KO
	
	#In ogni caso devo mandare una resonse a Wind...
	MS_CheckErrorsAndSendResponseToWind(\%MS_ConfigHash);



print "\nResponseHash:\n".Dumper(\$MS_ConfigHash{ResponseHash});

#my $XMLHash_ptr = MS_XMLCheckParsing($TicketHash_ptr, $TicketHash_ptr->{ResponseHash}->{ResponseContent});
#print "\n\nXMLHash_ptr:\n".Dumper(\$XMLHash_ptr);




















# ----------------------- sub di supporto ----------------
sub MS_CheckErrorsAndSendResponseToWind
{
	my $MS_ConfigHash_ptr = shift;
	
	
	my $statusCode = 1; #errore
	if ( (exists($MS_ConfigHash_ptr->{RequestHash}->{RequestErrorCode}) and $MS_ConfigHash_ptr->{RequestHash}->{RequestErrorCode} == 0)
			and
			(exists($MS_ConfigHash_ptr->{Errors}->{ExternalCode}) and $MS_ConfigHash_ptr->{Errors}->{ExternalCode} == 0)
			and
			(exists($MS_ConfigHash_ptr->{Errors}->{InternalCode}) and $MS_ConfigHash_ptr->{Errors}->{InternalCode} == 0)
		)
	{
		$statusCode = 0; #nessun errore
	}
	
	print "\n\nTRANSACTION: ".$MS_ConfigHash_ptr->{RequestHash}->{TransactionId};
	
	my $infoHashForResponse = {
		StatusCode => $statusCode,
		#ErrorMessage => $MS_ConfigHash_ptr->{RequestHash}->{RequestErrorCode},
		#ErrorDescription => $MS_ConfigHash_ptr->{RequestHash}->{RequestErrorDescr},
		TransactionId => $MS_ConfigHash_ptr->{RequestHash}->{TransactionId},
		BusinessId => $MS_ConfigHash_ptr->{RequestHash}->{BusinessId},
		Username => $MS_ConfigHash_ptr->{RequestHash}->{Username},
		Password => $MS_ConfigHash_ptr->{RequestHash}->{Password},
		MessageType => $MS_ConfigHash_ptr->{RequestHash}->{MessageType},
		MessageCode => $MS_ConfigHash_ptr->{RequestHash}->{MessageCode},
		MessageId => $MS_ConfigHash_ptr->{RequestHash}->{MessageId},
		#TicketID => TicketID dell'Alarm appena creato,

		MS_InputRequestType => $MS_ConfigHash_ptr->{RequestHash}->{InputRequestType},
	};

	
	if ($statusCode != 0)
	{
		if ( (exists($MS_ConfigHash_ptr->{Errors}->{ExternalCode}) and $MS_ConfigHash_ptr->{Errors}->{ExternalCode} != 0)
			 and
			 (exists($MS_ConfigHash_ptr->{Errors}->{ExternalDescr}) and $MS_ConfigHash_ptr->{Errors}->{ExternalDescr} ne '')
			)
		{
			$infoHashForResponse->{ErrorMessage} = $MS_ConfigHash_ptr->{Errors}->{ExternalCode};
			$infoHashForResponse->{ErrorDescription} = $MS_ConfigHash_ptr->{Errors}->{ExternalDescr};
		}
		elsif ( (exists($MS_ConfigHash_ptr->{RequestHash}->{RequestErrorCode}) and $MS_ConfigHash_ptr->{RequestHash}->{RequestErrorCode} != 0)
			 and
			 (exists($MS_ConfigHash_ptr->{RequestHash}->{RequestErrorDescr}) and $MS_ConfigHash_ptr->{RequestHash}->{RequestErrorDescr} ne '')
			)
		{
			$infoHashForResponse->{ErrorMessage} = $MS_ConfigHash_ptr->{RequestHash}->{RequestErrorCode};
			$infoHashForResponse->{ErrorDescription} = $MS_ConfigHash_ptr->{RequestHash}->{RequestErrorDescr};
		}
		elsif( (exists($MS_ConfigHash_ptr->{Errors}->{InternalCode}) and $MS_ConfigHash_ptr->{Errors}->{InternalCode} != 0) )
		{
			$infoHashForResponse->{ErrorMessage} = 400;
			$infoHashForResponse->{ErrorDescription} = 'Errore interno';
		}
		else
		{
			$infoHashForResponse->{ErrorMessage} = 401;
			$infoHashForResponse->{ErrorDescription} = 'Errore interno';
		}
		
		
		
		#Log dell'eventuale errore
		my $EC = $MS_ConfigHash_ptr->{Errors}->{ExternalCode};
		my $ED = $MS_ConfigHash_ptr->{Errors}->{ExternalDescr};
		my $REC = $MS_ConfigHash_ptr->{RequestHash}->{RequestErrorCode};
		my $RED = $MS_ConfigHash_ptr->{RequestHash}->{RequestErrorDescr};
		my $IC = $MS_ConfigHash_ptr->{Errors}->{InternalCode};
		my $ID = $MS_ConfigHash_ptr->{Errors}->{InternalDescr};
		
		
		$MS_ConfigHash_ptr->{OTRS_LogObject}->Log( Priority => 'error', Message => "$MS_ConfigHash_ptr->{log_prefix} - Error Codes: ExternalCode=$EC, ExternalDescr=$ED, RequestErrorCode=$REC, RequestErrorDescr=$RED,  InternalCode=$IC, InternalDescr=$ID");		
	}
	
	$infoHashForResponse->{TicketID} = $MS_ConfigHash_ptr->{NewAlarmID} if(defined($MS_ConfigHash_ptr->{NewAlarmID}) and $MS_ConfigHash_ptr->{NewAlarmID} > 0);
	
	
	my $responseString = MS_ResponseBuildAndSend($infoHashForResponse);
	
	
	
	#Log della Reponse...
	if ($MS_ConfigHash_ptr->{PM_Wind_settings}->{log_level} >= 2)
	{
		$MS_ConfigHash_ptr->{OTRS_LogObject}->Log( Priority => 'notice', Message => "$MS_ConfigHash_ptr->{log_prefix} - Request from Wind: ".$MS_ConfigHash_ptr->{RequestHash}->{RequestContent});
		$MS_ConfigHash_ptr->{OTRS_LogObject}->Log( Priority => 'notice', Message => "$MS_ConfigHash_ptr->{log_prefix} - Response to Wind: $responseString");
	}
	
	
	#Log dell'oggetto principale nel log_level massimo
	if ($MS_ConfigHash_ptr->{PM_Wind_settings}->{log_level} > 2)
	{
		#Faccio una copia dell'oggetto principale
		my %MS_ConfigHash_OnlyForLog = %{$MS_ConfigHash_ptr};
		
		#...e lo ripulisco dalla parte OTRS (che e' prolissa e non mi aggiunge info utili)
		delete $MS_ConfigHash_OnlyForLog{OTRS_ConfigObject};
		delete $MS_ConfigHash_OnlyForLog{OTRS_EncodeObject};
		delete $MS_ConfigHash_OnlyForLog{OTRS_LogObject};
		delete $MS_ConfigHash_OnlyForLog{OTRS_MainObject};
		delete $MS_ConfigHash_OnlyForLog{OTRS_DBObject};
		delete $MS_ConfigHash_OnlyForLog{OTRS_TimeObject};
		delete $MS_ConfigHash_OnlyForLog{OTRS_TicketObject};
		delete $MS_ConfigHash_OnlyForLog{OTRS_XMLObject};
		
		#e adesso loggo
		use Data::Dumper;
		$MS_ConfigHash_ptr->{OTRS_LogObject}->Log( Priority => 'notice', Message => "$MS_ConfigHash_ptr->{log_prefix} - ConfigHash DUMP:\n".Dumper(\%MS_ConfigHash_OnlyForLog) );
	}	
}





# ----------------------- sub di supporto ----------------
sub MS_SendResponseToWindOnBadRequestAndTerminate
{
	my $MS_ConfigHash_ptr = shift;

	MS_CheckErrorsAndSendResponseToWind($MS_ConfigHash_ptr);
	
	#termino l'esecuzione visto che si e' verificato un errore
	exit(0);	
}











