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






#***********************************************************************************************************
#******************                          Configurazione                           **********************
#***********************************************************************************************************


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






# ----------------- Moduli custom necessari ------------------
use MSErrorUtil;
use MSConfigUtil;
use MSHttpUtil;
use MSRequestFromWindUtil;
use MSResponseToWindUtil;
use MSRequestFromWindActionsUtil;







# ----------------- Inizializzazione oggetti OTRS ------------------

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
          


    my $TicketObject = Kernel::System::Ticket->new(
        ConfigObject => $ConfigObject,
        LogObject    => $LogObject,
        DBObject     => $DBObject,
        MainObject   => $MainObject,
        TimeObject   => $TimeObject,
        EncodeObject => $EncodeObject,
        #GroupObject  => $GroupObject,              # if given
        #CustomerUserObject => $CustomerUserObject, # if given
        #QueueObject        => $QueueObject,        # if given
    );


    my $XMLObject = Kernel::System::XML->new(
        ConfigObject => $ConfigObject,
        LogObject    => $LogObject,
        DBObject     => $DBObject,
        MainObject   => $MainObject,
        EncodeObject => $EncodeObject,
    );

# ----------------- Inizializzazione oggetti OTRS (fine) ------------------







# ----------------- Hash di configurazione ------------------

#Hash GLOBALE che contiene TUTTE le configurazioni, anche quelle lette dal file di config e i riferimenti agli oggetti OTRS
my %MS_ConfigHash = (
   #config_file_name => "$Bin/../../Kernel/pm_wind/config_pm_wind.conf",
	log_prefix => '_MSFull_ [TTActionReceiver_PMWind.pl]:',  #la parte _MSFull_ torna utile per filtrare tutti i log che arrivano dal Full e non solo da questo servizio...
	
	#oggetti OTRS
	OTRS_ConfigObject => $ConfigObject,
	OTRS_EncodeObject => $EncodeObject,
	OTRS_LogObject => $LogObject,
	OTRS_MainObject => $MainObject,
	OTRS_DBObject => $DBObject,
	OTRS_TimeObject => $TimeObject,
	OTRS_TicketObject => $TicketObject,
   OTRS_XMLObject => $XMLObject,
	
	#configurazioni
	PM_Wind_settings => '', #puntatore all'hash di configurazione specifico per PM_Wind che arriva dal Ticket.xml
	Category_Incident_PM_Wind => '', #puntatore all'elenco category Incident PM_Wind che arriva dal Ticket.xml
	Category_Alarm_PM_Wind => '', #puntatore all'elenco category Alarm PM_Wind che arriva dal Ticket.xml
	Category_Alarm_Wind_PM => '', #puntatore all'elenco category Alarm Wind_PM che arriva dal Ticket.xml
	
	#info
	NewAlarmID => '', #settato solo da una Create Alarm...
	Errors => {
		ExternalCode => 0, # 0 = tutto ok -- da esportare verso Wind
		ExternalDescr => '',
		
		InternalCode => 0, # 0 = tutto ok - uso interno
		InternalDescr => '', #uso interno
		StopEsecution => 0, #uso interno - messo ad 1 mi fa chiamare una exit dopo un errore...
	},
	
	
	
	#request
	RequestHash => {
							#MS info (non arrivano nella request ma li valorizza internamente)
							RequestTypeCREATE => 'CREATE',
							RequestTypeUPDATE => 'UPDATE',
							RequestTypeNOTIFY => 'NOTIFY',
							RequestType => '', #CREATE, UPDATE, NOTIFY --> RequestTypeCREATE, RequestTypeUPDATE, RequestTypeNOTIFY
							RequestContent => '', #il contenuto della request cosi' come arriva al server
							RequestErrorCode => 0, # 0 = tutto ok 
							RequestErrorDescr => '',
							
							TicketID_is_a_TN => 1, #ad 1 se con Wind scambiamo il TN del ticket invece del suo ID
							#MS info -- fine
							
							#di seguito aggiungero' i campi specicfici della request (se assenti sono da considerarsi non presenti nella request in arrivo)

							## --- Request header ---
							#SourceChannel => '',
							#DestinationChannel => '',
							#TimeStamp => '',
							#Username => '',
							#Password => '',
							#MessageType => '',
							#MessageCode => '',
							#TransactionId => '',
							#MessageId => '',
							#BusinessId => '',
							#
							## --- Request body ---
							#TicketID => '',
							#TickedIDWind => '',
							#Causale => '', #valida solo in NOTIFY
							#Action => '',
							#Status => '',
							#Type => '',
							#priority => '',
							#CategoryTT => '',
							#AmbitoTT => '',
							#Oggetto => '',
							#Descrizione => '',
							#TimestampTT => '',
							#startDateMalfunction => '',
							#endDateMalfunction => '',
							#segmentCustomer => '',
							#msisdn => '',
							#imsi => '',
							#iccid => '',
							#idLinea => '',
							#tipoLinea => '',
							#mnpType => '',
							#imei => '',
							#ErrorCode => '',
							#ErrorDesc => '',
							#ExpDate => '', # ExpirationDate_TTL valida solo in NOTIFY
							#Referente => '',
							#Nota => '',
							#address => '',
							#prov => '',
							#city => '',
							#cap => '',
							#
							## --- Allegati ---
							#AttachedFiles => [
							#							{
							#								FullFileName => '',
							#								TypeFile => '',
							#								dataCreazione => '',
							#								FileBody => '',
							#							},
							#
							#							{
							#								FullFileName => '',
							#								TypeFile => '',
							#								dataCreazione => '',
							#								FileBody => '',
							#							},
							#						],
							#
						}
	

);
#my $MS_ConfigHash_ptr = \%MS_ConfigHash; #ptr di "convenienza" (uniformo chiamate come da sub-moduli)

# ----------------- Hash di configurazione (fine) ------------------

#***********************************************************************************************************
#******************                      Fine Configurazione                      **************************
#***********************************************************************************************************







MS_main();







# ---------------------------------------------------------------------------------------------
# ------------------------------- inizio flusso elaborativo reale -----------------------------
sub MS_main
{
	#Controllo la configurazione specifica...
	MS_LoadAndCheckConfigForWind(\%MS_ConfigHash);
	
	#Controllo eventuali errori e mi comporto di conseguenza
	MS_CheckInternalErrorAndSendResponse($MS_ConfigHash{Errors}, $MS_ConfigHash{OTRS_LogObject});
	
	
	
	
	
	
	#Leggo quello che arriva via HTTP POST...
	MS_ReadHttpPost (\$MS_ConfigHash{RequestHash}->{RequestContent},
						  $MS_ConfigHash{OTRS_LogObject},
						  $MS_ConfigHash{PM_Wind_settings}->{log_level},
						  $MS_ConfigHash{Errors}
						 );
	
	#Controllo eventuali errori e mi comporto di conseguenza
	MS_CheckInternalErrorAndSendResponse($MS_ConfigHash{Errors}, $MS_ConfigHash{OTRS_LogObject});
	
	
	
	
	
	
	
	#provo a fare il parsing della Request...
	MS_RequestParsing(\%MS_ConfigHash);
	
	#Controllo eventuali errori interni e mi comporto di conseguenza
	#MS_CheckInternalErrorAndSendResponse($MS_ConfigHash{Errors}, $MS_ConfigHash{OTRS_LogObject});
	
	#Verifico se esiste qualche errore relativo al parsing della Request
	if ($MS_ConfigHash{RequestHash}->{RequestErrorCode} != 0)
	{
		MS_SendResponseToWindOnBadRequestAndTerminate(\%MS_ConfigHash);
	}
	
	
	
	
	
	
	
	# Controllo eventuali errori semantici nella Request
	my $semantic_rit = MS_CheckRequestSemantic(\%MS_ConfigHash); # Ritorna 1 se OK, 0 se KO
	
	#Verifico se esiste qualche errore relativo alla semantica della Request
	if ($MS_ConfigHash{RequestHash}->{RequestErrorCode} != 0 or !$semantic_rit) 
	{
		MS_SendResponseToWindOnBadRequestAndTerminate(\%MS_ConfigHash);
	}
	
	
	
	
	
	
	my $actionResult = MS_do_action(\%MS_ConfigHash); # Ritorna 1 se OK, 0 se KO
	
	#In ogni caso devo mandare una resonse a Wind...
	MS_CheckErrorsAndSendResponseToWind(\%MS_ConfigHash);
	
	exit(0);
}
# ----------------------- inizio flusso elaborativo reale (fine) ----------------


















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
	
	
	my $infoHashForResponse = {
		StatusCode => $statusCode,
		#ErrorMessage => $MS_ConfigHash_ptr->{RequestHash}->{RequestErrorCode},
		#ErrorDescription => $MS_ConfigHash_ptr->{RequestHash}->{RequestErrorDescr},
		TransactionId => $MS_ConfigHash_ptr->{RequestHash}->{TransactionId},
		#TicketID => TicketID dell'Alarm appena creato,
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



    